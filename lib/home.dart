import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/history.dart';
import 'package:geolocator/geolocator.dart';
import 'NearestLandmarksPage.dart';
import 'all.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'landmark.dart';
import 'Landmark_Data.dart';
import 'User.dart';
import 'profile.dart';
import 'user_data.dart';
import 'favourites.dart';

// void main() {
//   runApp(MaterialApp(
//     title: 'Navigation Basics',
//     home: Welcome(),
//   ));

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<LandmarkData?> _getLandmarkData(String landmarkName) async {
    String apiUrl = Constants.baseUrl + "/api/Landmark/name/$landmarkName";
    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      Map<String, dynamic>? data = jsonResponse['data'];

      if (data != null) {
        return LandmarkData.fromJson(data);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> _search(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Searching..."),
            ],
          ),
        );
      },
    );

    List<int>? imageBytes = await _getImageBytes();

    if (imageBytes == null) {
      print("Image is null");
      // Hide loading indicator
      Navigator.of(context).pop();
      return;
    }

    String predictionResult = await _sendImageToPredictAPI(imageBytes);
    if (predictionResult == "Not Found") {
      // Hide loading indicator
      Navigator.of(context).pop();

      // Show alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Similar Landmark"),
            content: Text("Please try uploading a different photo."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      return;
    }

    LandmarkData? landmarkData = await _getLandmarkData(predictionResult);
    _addToHistory(landmarkData!.id);
    if (landmarkData != null) {
      print("LandmarkData: $landmarkData");

      Navigator.pop(context); // Hide loading indicator

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Landmark(landmarkData: landmarkData),
        ),
      );
    } else {
      print("LandmarkData is null");
      // Hide loading indicator
      Navigator.of(context).pop();
    }
  }

  Future<List<int>?> _getImageBytes() async {
    if (selectedImagePath.startsWith('assets/')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Image Found"),
            content: Text("Please Upload An Image."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return null;
    } else {
      try {
        File imageFile = File(selectedImagePath);
        return await imageFile.readAsBytes();
      } catch (e) {
        print("Exception while converting image to bytes: $e");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Error converting image to bytes."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return null;
      }
    }
  }

  Future<String> _sendImageToPredictAPI(List<int> imageBytes) async {
    final apiUrl = Constants.baseUrl + '/api/Landmark/predict';

    try {
      String base64Image = base64Encode(imageBytes);

      Map<String, dynamic> imageData = {"image": base64Image};

      String requestBody = jsonEncode(imageData);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        String predictionResult = jsonResponse['result'];
        return predictionResult;
      } else {
        print("Error: ${response.statusCode}");
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      // Handle exceptions
      print("Exception: $e");
      return "Error: $e";
    }
  }

  String selectedImagePath = 'assets/placeholder.jpg';
  List<LandmarkData> landmarkList = [];
  List<LandmarkData> filteredList = [];
  @override
  void initState() {
    super.initState();
    _fetchLandmarks();
  }

  void _showSearchWidget(BuildContext context) {
    filteredList.clear(); // Clear the list every time before showing the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Search'),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height *
                    0.5, // Adjust the height of the dialog content
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        if (value.length >= 2) {
                          _searchWithName(
                              context, value); // Update suggestions list
                          setState(() {}); // Update the dialog content
                        } else {
                          setState(() {
                            filteredList
                                .clear(); // Clear the list if less than 2 characters
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (filteredList.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context); // Close the dialog
                                _navigateToLandmarkPage(
                                    filteredList[index].name);
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              },
                              title: Text(
                                filteredList[index].name,
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    if (landmarkList.isNotEmpty) {
      print("First Landmark in the List:");
      print("ID: ${landmarkList[0].id}");
      print("Name: ${landmarkList[0].name}");
    }
    return GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            filteredList = [];
          });
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 80, 0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                            ),
                            child: Icon(Icons.arrow_back, color: Colors.black),
                          ),
                          Spacer(),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                'assets/logo.png',
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          _showSearchWidget(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search By Name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Do you have a photo ?",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        _openImagePicker(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: selectedImagePath.startsWith('assets/')
                            ? Image.asset(
                                selectedImagePath,
                                width: 250,
                                height: 180,
                              )
                            : Image.file(
                                File(selectedImagePath),
                                width: 250,
                                height: 180,
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 299,
                      height: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _search(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF176FF2),
                          ),
                          child: Text("Search"),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Popular",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllLandmarks(),
                                ),
                              );
                            },
                            child: Text(
                              "See all",
                              style: TextStyle(
                                color: Color(0xFF176FF2),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (landmarkList.isNotEmpty) {
                              LandmarkData? landmarkDataa =
                                  await _getLandmarkData(landmarkList[0].name);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Landmark(landmarkData: landmarkDataa!),
                                ),
                              );
                            }
                          },
                          child: _buildClickableFrame(
                            'assets/10.jpg',
                            landmarkList.isNotEmpty ? landmarkList[0].name : '',
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (landmarkList.length > 1) {
                              LandmarkData? landmarkDataa =
                                  await _getLandmarkData(landmarkList[1].name);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Landmark(landmarkData: landmarkDataa!),
                                ),
                              );
                            }
                          },
                          child: _buildClickableFrame(
                            'assets/2.jpg',
                            landmarkList.length > 1 ? landmarkList[1].name : '',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 300,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _getCurrentLocation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary:
                                Color(0xFF176FF2), // Background color of button
                            onPrimary: Colors.white, // Text color of button
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.near_me,
                                color: Colors.white, // Color of the map icon
                              ),
                              SizedBox(
                                  width:
                                      10), // Adjust the spacing between icon and text
                              Text(
                                "Landmarks near you",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context),
          ),
        ));
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: BottomNavigationBar(
        selectedItemColor: Color(0xFF176FF2),
        unselectedItemColor: Colors.grey[300],
        currentIndex: 0,
        onTap: (index) {
          _onBottomNavigationBarItemTapped(context, index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onBottomNavigationBarItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => History()),
        );
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavouritesPage()),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  Widget _buildClickableFrame(String imagePath, String labelText) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: 140,
            height: 120,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _openImagePicker(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImagePath = File(pickedFile!.path).absolute.path;
      });
      print("Image selected: ${pickedFile.path}");
    }
  }

  void _searchWithName(BuildContext context, String query) {
    setState(() {
      filteredList = landmarkList
          .where((landmark) =>
              landmark.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToLandmarkPage(String landmarkName) async {
    LandmarkData? landmarkData = await _getLandmarkData(landmarkName);
    _addToHistory(landmarkData!.id);
    if (landmarkData != null) {
      print("LandmarkData: $landmarkData");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Landmark(landmarkData: landmarkData),
        ),
      );
    } else {
      print("LandmarkData is null");
    }
  }

  Future<void> _addToHistory(int landmarkId) async {
    final url = Uri.parse(Constants.baseUrl +
        "/api/Landmark/add-history/${currentUser?.id}/${landmarkId}");
    final headers = {'Content-Type': 'application/json'};
    print({currentUser?.id});

    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        print('Search history added successfully');
      } else {
        print('Failed to add search history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding search history: $e');
    }
  }

  Future<void> _fetchLandmarks() async {
    String apiUrl = Constants.baseUrl + "/api/Landmark";

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> landmarkDataList = responseData['data'];

          List<LandmarkData> fetchedLandmarks = landmarkDataList.map((data) {
            return LandmarkData(
              id: data['id'],
              name: data['name'],
              egyptianTicketPrice: data['egyptianTicketPrice'],
              egyptianStudentTicketPrice: data['egyptianStudentTicketPrice'],
              foreignTicketPrice: data['foreignTicketPrice'],
              foreignStudentTicketPrice: data['foreignStudentTicketPrice'],
              description: data['description'],
              openTime: data['openTime'],
              closeTime: data['closeTime'],
              longitude: data['longitude'],
              latitude: data['latitude'],
              images: data['imagesUrl'] != null
                  ? List<String>.from(data['imagesUrl'])
                  : null,
            );
          }).toList();

          setState(() {
            landmarkList = fetchedLandmarks;
          });

          print("Landmark List:");
          for (var landmark in landmarkList) {
            print("ID: ${landmark.id}");
            print("Name: ${landmark.name}");
            print("images: ${landmark.images}");
            print("----------------------");
          }
        } else {
          print("Invalid data structure in API response.");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception: $error");
    }
  }
  void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dialog from closing when tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Loading..."),
          ],
        ),
      );
    },
  );
}
void _getCurrentLocation(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Loading..."),
          ],
        ),
      );
    },
  );

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Navigator.of(context).pop(); // Hide loading indicator
    print('Location services are disabled');
    return;
  }

  // Request location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    Navigator.of(context).pop(); // Hide loading indicator
    print('Location permissions are permanently denied, we cannot request permissions.');
    return;
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      Navigator.of(context).pop(); // Hide loading indicator
      print('Location permissions are denied (actual value: $permission).');
      return;
    }
  }

  // Get current location
  try {
    Position position = await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: true,
      desiredAccuracy: LocationAccuracy.best,
    ).timeout(Duration(seconds: 20));

    print(position.latitude);
    print(position.longitude);

    Navigator.of(context).pop(); // Hide loading indicator

    // Navigate to nearest landmarks page with current location coordinates
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearestLandmarksPage(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // Hide loading indicator
    print('Error getting current location: $e');
  }
}
}




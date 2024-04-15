import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'all.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'landmark.dart';
import 'Landmark_Data.dart';
import 'User.dart';
import 'profile.dart';
// void main() {
//   runApp(MaterialApp(
//     title: 'Navigation Basics',
//     home: Welcome(),
//   ));

class Home extends StatefulWidget {
  final User user;

  const Home({Key? key, required this.user}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<LandmarkData?> _getLandmarkData(String landmarkName) async {
    String apiUrl = Constants.baseUrl+"/api/Landmark/name/$landmarkName";
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
    final apiUrl = Constants.baseUrl+'/api/Landmark/predict';

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
                              primary: Colors.transparent,
                              elevation: 0,
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
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          if (value.length >= 3) {
                            _searchWithName(context, value);
                          } else {
                            setState(() {
                              filteredList = [];
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
                    ),
                    SizedBox(height: 15),
                    if (filteredList.isNotEmpty)
                      Container(
                        color: Colors.grey[300],
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                _navigateToLandmarkPage(
                                    filteredList[index].name);
                              },
                              title: Text(
                                filteredList[index].name,
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          },
                        ),
                      ),
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
                            primary: Color(0xFF176FF2),
                          ),
                          child: Text("Search"),
                        ),
                      ),
                    ),
                    SizedBox(height: 45),
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
                          onTap: () {
                            if (landmarkList.isNotEmpty) {
                              _navigateToLandmarkPage(landmarkList[0].name);
                            }
                          },
                          child: _buildClickableFrame(
                            'assets/10.jpg',
                            landmarkList.isNotEmpty ? landmarkList[0].name : '',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (landmarkList.length > 1) {
                              _navigateToLandmarkPage(landmarkList[1].name);
                            }
                          },
                          child: _buildClickableFrame(
                            'assets/2.jpg',
                            landmarkList.length > 1 ? landmarkList[1].name : '',
                          ),
                        ),
                      ],
                    )
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
          MaterialPageRoute(builder: (context) => Home(user: widget.user)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
                    user: widget.user,
                  )),
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

  Future<void> _fetchLandmarks() async {
    String apiUrl = Constants.baseUrl+"/api/Landmark";

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
}

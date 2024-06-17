import 'package:flutter/material.dart';
import 'dart:convert';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'history.dart';
import 'home.dart';
import 'landmark.dart';
import 'profile.dart';
import 'user_data.dart';
import 'Landmark_Data.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({
    Key? key,
  }) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<LandmarkData> landmarkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavouriteLandmarks(currentUser?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Landmarks'),
        centerTitle: true,
        backgroundColor: Color(0xFF176FF2), // Set app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Change icon color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildFavouriteLandmarkListView(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(), // Display a circular progress indicator
    );
  }

  Widget _buildFavouriteLandmarkListView() {
    return ListView.builder(
      itemCount: landmarkList.length,
      itemBuilder: (context, index) {
        LandmarkData landmarkData = landmarkList[index];

        List<String> landmarkImages = landmarkData.images
                ?.map((url) => Constants.baseUrl + '/$url')
                .toList() ??
            [];

        return GestureDetector(
          onTap: () {
            _navigateToLandmarkDetailsPage(landmarkData);
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Column(
              children: [
                if (landmarkImages.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      landmarkImages[0],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            landmarkData.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _toggleFavourite(landmarkData.id);
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red, // Change color based on favourite status
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        landmarkData.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EGP ${landmarkData.foreignTicketPrice}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF176FF2),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _navigateToLandmarkDetailsPage(landmarkData);
                            },
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                color: Color(0xFF176FF2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToLandmarkDetailsPage(LandmarkData landmarkData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Landmark(landmarkData: landmarkData),
      ),
    );
  }

  Future<void> _fetchFavouriteLandmarks(String? userId) async {
    setState(() {
      isLoading = true; // Set loading state
    });

    String apiUrl = Constants.baseUrl + "/api/Landmark/getFavourites/${userId}";

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> landmarkDataList = responseData['data'];

          List<LandmarkData> fetchedLandmarks = landmarkDataList.map((data) {
            List<dynamic> imagesData = data['images'];
            List<String> imagesUrls = [];

            for (var imageData in imagesData) {
              if (imageData.containsKey('url')) {
                imagesUrls.add(imageData['url']);
              }
            }
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
              images: imagesUrls.isNotEmpty ? imagesUrls : null,
            );
          }).toList();

          setState(() {
            landmarkList = fetchedLandmarks;
            isLoading = false; // Set loading state to false after fetching data
          });
        } else {
          print("Invalid data structure in API response.");
          setState(() {
            isLoading = false; // Set loading state to false on error
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false; // Set loading state to false on error
        });
      }
    } catch (error) {
      print("Exception: $error");
      setState(() {
        isLoading = false; // Set loading state to false on exception
      });
    }
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
        currentIndex: 2,
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
  Future<void> _toggleFavourite(int landmarkId) async {
    String apiUrl = Constants.baseUrl + "/api/Landmark/toggleFavourite/${currentUser?.id}/$landmarkId";

    try {
      var response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Fetch favourites again to update UI
        await _fetchFavouriteLandmarks(currentUser?.id);
      } else {
        print("Error toggling favourite: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception toggling favourite: $error");
    }
  }
}

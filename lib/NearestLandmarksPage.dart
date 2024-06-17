import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'landmark.dart';
import 'Landmark_Data.dart';

class NearestLandmarksPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  NearestLandmarksPage({required this.latitude, required this.longitude});

  @override
  _NearestLandmarksPageState createState() => _NearestLandmarksPageState();
}

class _NearestLandmarksPageState extends State<NearestLandmarksPage> {
  List<LandmarkData> nearestLandmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNearestLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Landmarks'),
        backgroundColor: Color(0xFF176FF2), // Set app bar color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : nearestLandmarks.isNotEmpty
              ? _buildLandmarkListView()
              : Center(
                  child: Text('No landmarks found within 50 km.'),
                ),
    );
  }

  Widget _buildLandmarkListView() {
    return ListView.builder(
      itemCount: nearestLandmarks.length,
      itemBuilder: (context, index) {
        LandmarkData landmarkData = nearestLandmarks[index];

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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
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
                      Text(
                        landmarkData.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

  Future<void> fetchNearestLandmarks() async {
    setState(() {
      isLoading = true;
    });

    String apiUrl =
        '${Constants.baseUrl}/api/Landmark/getNearestLandmarks/${widget.longitude}/${widget.latitude}';

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
            nearestLandmarks = fetchedLandmarks;
            isLoading = false; // Set loading state to false after fetching data
          });

          print("Nearest Landmark List:");
          for (var landmark in nearestLandmarks) {
            print("ID: ${landmark.id}");
            print("Name: ${landmark.name}");
            print("Images: ${landmark.images}");
            print("----------------------");
          }
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
}

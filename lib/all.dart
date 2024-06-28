import 'package:flutter/material.dart';
import 'dart:convert';
import 'constants.dart';
import 'landmark.dart';
import 'package:http/http.dart' as http;
import 'Landmark_Data.dart';

class AllLandmarks extends StatefulWidget {
  const AllLandmarks({
    Key? key,
  }) : super(key: key);

  @override
  _AllLandmarksState createState() => _AllLandmarksState();
}

class _AllLandmarksState extends State<AllLandmarks> {
  List<LandmarkData> landmarkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Landmarks'),
        centerTitle: true,
        backgroundColor: Color(0xFF176FF2), // Set app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildLandmarkListView(),
            ),
    );
  }

  Widget _buildLandmarkListView() {
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

  Future<void> _fetchLandmarks() async {
  setState(() {
    isLoading = true; // Set loading state
  });

  String apiUrl = Constants.baseUrl + "/api/Landmark";

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

          // Strip HTML tags from the description
          String cleanedDescription = _stripHtmlTags(data['description']);

          return LandmarkData(
            id: data['id'],
            name: data['name'],
            egyptianTicketPrice: data['egyptianTicketPrice'],
            egyptianStudentTicketPrice: data['egyptianStudentTicketPrice'],
            foreignTicketPrice: data['foreignTicketPrice'],
            foreignStudentTicketPrice: data['foreignStudentTicketPrice'],
            description: cleanedDescription,
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

        print("Landmark List:");
        for (var landmark in landmarkList) {
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
String _stripHtmlTags(String htmlString) {
  // Remove specific <p> and </p> tags
  return htmlString.replaceAll(RegExp(r'<\/?p>'), '');
}
}

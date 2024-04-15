import 'package:flutter/material.dart';
import 'Landmark_Data.dart';
import 'dart:convert';
import 'constants.dart';
import 'landmark.dart';
import 'package:http/http.dart' as http;

class AllLandmarks extends StatefulWidget {
  const AllLandmarks({
    Key? key,
  }) : super(key: key);

  @override
  _AllLandmarksState createState() => _AllLandmarksState();
}

class _AllLandmarksState extends State<AllLandmarks> {
  List<LandmarkData> landmarkList = [];

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildLandmarkListView(),
    );
  }

  Widget _buildLandmarkListView() {
    return ListView.builder(
      itemCount: landmarkList.length,
      itemBuilder: (context, index) {
        LandmarkData landmarkData = landmarkList[index];

        List<String> landmarkImages = landmarkData.images
                ?.map((url) => Constants.baseUrl+'/$url')
                .toList() ??
            [];

        return GestureDetector(
          onTap: () {
            _navigateToLandmarkDetailsPage(landmarkData);
          },
        child: Center(
          child: Container(
            width: 400,
            child: Column(
              children: [
                if (landmarkImages.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(
                          landmarkImages[0],
                          width: 400,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                landmarkData.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (landmarkImages.isEmpty)
                  Center(
                    child: Text(
                      'No images available for ${landmarkData.name}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        )
        );
      },
    );
  }
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 8),
          Text(
            'All Landmarks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
    String apiUrl = Constants.baseUrl+"/api/Landmark";

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
              images: imagesUrls.isNotEmpty ? imagesUrls : null
            );
          }).toList();

          setState(() {
            landmarkList = fetchedLandmarks;
          });

          print("Landmark List:");
          for (var landmark in landmarkList) {
            print("ID: ${landmark.id}");
            print("Name: ${landmark.name}");
            print("iamges: ${landmark.images}");
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

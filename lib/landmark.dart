

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Landmark_Data.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class Landmark extends StatefulWidget {
  final LandmarkData landmarkData; 

  Landmark({required this.landmarkData});

  @override
  _LandmarkState createState() => _LandmarkState();
}

class _LandmarkState extends State<Landmark> {
  int currentIndex = 0;
  bool isFavorite = false; 
  bool showFullDescription = false;
  @override
  Widget build(BuildContext context) {
    String landmarkDescription = widget.landmarkData.description;
    String LandmarkName = widget.landmarkData.name;
    double latitude = widget.landmarkData.latitude;
    double longitude = widget.landmarkData.longitude;
    double studentPrice = widget.landmarkData.foreignStudentTicketPrice;
    double adultPrice = widget.landmarkData.foreignTicketPrice;
    String openTime = _formatTime(widget.landmarkData.openTime);
    String closeTime = _formatTime(widget.landmarkData.closeTime);
    List<String> landmarkImages = widget.landmarkData.images
            ?.map((url) => Constants.baseUrl+'/$url')
            ?.toList() ??
        [];
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.infinity,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: landmarkImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          landmarkImages[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors
                                .white, // You can change the background color here
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          landmarkImages.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index
                                  ? Color(0xFF176FF2)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            LandmarkName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        Text(
                          openTime == closeTime
                              ? 'Open 24 hours'
                              : '$openTime - $closeTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF176FF2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              landmarkDescription.trim(), // Trim whitespace
                              overflow: TextOverflow.clip,
                              maxLines: showFullDescription ? null : 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showFullDescription = !showFullDescription;
                        });
                      },
                      child: Text(
                        showFullDescription ? 'Read Less' : 'Read More',
                        style: TextStyle(
                          color: Color(0xFF176FF2),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Entrance Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Student',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentPrice == 0
                                  ? 'No Fees'
                                  : 'EGP $studentPrice',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF2DD7A4),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Adult',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              adultPrice == 0 ? 'No Fees' : 'EGP $adultPrice',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF2DD7A4),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 38),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _launchMapsUrl(latitude, longitude);
                        },
                        icon: Icon(Icons.location_on),
                        label: Text('Show on Maps',
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF176FF2),
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  void _launchMapsUrl(double lat, double lng) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(googleUrl) != null) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

String _formatTime(String time) {
  final parsedTime = DateFormat('HH:mm:ss').parse(time);
  final formattedTime = DateFormat.jm().format(parsedTime);
  return formattedTime;
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Landmark_Data.dart';
import 'constants.dart';
import 'favourites.dart';
import 'home.dart';
import 'landmark.dart';
import 'user_data.dart'; // Assuming currentUser is defined here

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<LandmarkData> historyLandmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoryLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
          : _buildHistoryListView(),
      bottomNavigationBar: _buildBottomNavigationBar(context),   
    );
    
  }

  Widget _buildHistoryListView() {
    return ListView.builder(
      itemCount: historyLandmarks.length,
      itemBuilder: (context, index) {
        LandmarkData landmarkData = historyLandmarks[index];
        return GestureDetector(
          onTap: () {
            _navigateToLandmarkDetailsPage(landmarkData);
          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  landmarkData.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

  Future<void> _fetchHistoryLandmarks() async {
    setState(() {
      isLoading = true; // Set loading state
    });

    String apiUrl = Constants.baseUrl + "/api/Landmark/getHistory/${currentUser?.id}"; // Replace with your API endpoint for fetching history

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
              images: [], // You can handle images as needed
            );
          }).toList();

          setState(() {
            historyLandmarks = fetchedLandmarks;
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
        currentIndex: 1,
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
}

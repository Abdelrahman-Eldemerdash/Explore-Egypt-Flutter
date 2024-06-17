import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'favourites.dart';
import 'history.dart';
import 'home.dart';
import 'User.dart';
import 'user_data.dart'; // Import the global variable

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ProfilePage(user: currentUser!), // Use currentUser
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
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
        currentIndex: 3,
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => History()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavouritesPage()),
        );
        break;
      case 3:
        // Stay on the Profile page
        break;
    }
  }
}

class ProfilePage extends StatelessWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Image.asset(
              'assets/logo.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Profile details with icons
            buildProfileDetail(Icons.person, 'First Name', user.firstName),
            buildProfileDetail(Icons.person, 'Last Name', user.lastName),
            buildProfileDetail(Icons.email, 'Email', user.email),
            buildProfileDetail(Icons.lock, 'Password', '*********'), // Display password securely
            buildProfileDetail(Icons.location_on, 'Country', user.country),
            SizedBox(height: 20),
            // Logout button
            ElevatedButton(
              onPressed: () {
                // Perform logout logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF176FF2), // Set button color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileDetail(IconData iconData, String labelText, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            iconData,
            size: 32,
            color: Color(0xFF176FF2),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

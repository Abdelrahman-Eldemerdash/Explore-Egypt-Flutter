import 'package:flutter/material.dart';
import 'home.dart';
import 'User.dart';

class Profile extends StatefulWidget {
  final User user; // Add a field to store the user object

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfilePage(user:widget.user),
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
        // Navigate to the Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(user: widget.user)),
        );
        break;

      // Repeat the process for other tabs as needed
    }
  }
}

class ProfilePage extends StatelessWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 16),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 34, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text fields for user data
              buildText('First Name', user.firstName),
              buildText('Last Name', user.lastName),
              buildText('Email', user.email),
              buildText('Password', user.password), 
              buildText('Country', user.country),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildText(String labelText, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 24, horizontal: 16), // Adjust vertical padding as needed
      child: Row(
        children: [
          Text(
            labelText + ': ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
          SizedBox(width: 8), // Adjust width as needed
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
        ],
      ),
    );
  }
}


  Widget buildText(String labelText, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 24, horizontal: 16), // Adjust vertical padding as needed
      child: Row(
        children: [
          Text(
            labelText + ': ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
          SizedBox(width: 8), // Adjust width as needed
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
        ],
      ),
    );
  }


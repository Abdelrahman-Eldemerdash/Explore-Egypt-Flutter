// import 'package:flutter/material.dart';
// import 'favourites.dart';
// import 'package:test_app/pages/history.dart';
// import 'package:test_app/pages/profile.dart';



// class Landmark {
//   final String name;
//   final String imagePath;

//   Landmark({required this.name, required this.imagePath});
// }

// class ALL extends StatefulWidget {
//   const ALL({super.key});

//   @override
//   _ALLState createState() => _ALLState();
// }

// class _HomeState extends State<ALL> {
//   List<Landmark> landmarks = [
//     Landmark(name: 'Eiffel Tower', imagePath: 'assets/eiffel-tower.jpeg'),
//     Landmark(name: 'Pyramids', imagePath: 'assets/pyramids.jpeg'),
//     // Add more landmarks as needed
//   ];

//   List<Landmark> favorites = [];
//   int _currentIndex = 0;

//   void _handleFavoritePress(Landmark landmark) {
//     setState(() {
//       if (favorites.contains(landmark)) {
//         favorites.remove(landmark);
//       } else {
//         favorites.add(landmark);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My App'),
//       ),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

  

//   Widget _buildBottomNavigationBar() {
//     return ClipRRect(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(20.0),
//         topRight: Radius.circular(20.0),
//       ),
//       child: BottomNavigationBar(
//         selectedItemColor: Color(0xFF176FF2),
//         unselectedItemColor: Colors.grey[300],
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           _handleTabPress(context, index);
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: 'Favorite',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleTabPress(BuildContext context, int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/history');
//         break;
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Favourites(favoriteLandmarks: favorites),
//           ),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//     }
//   }
// }


// class HomeContent extends StatelessWidget {
//   final List<Landmark> landmarks;
//   final List<Landmark> favorites;
//   final Function(Landmark) onFavoritePress;

//   HomeContent({
//     required this.landmarks,
//     required this.favorites,
//     required this.onFavoritePress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: _buildLandmarkListView(),
//     );
//   }

//   Widget _buildLandmarkListView() {
//     return ListView.builder(
//       itemCount: landmarks.length,
//       itemBuilder: (context, index) {
//         Landmark landmark = landmarks[index];
//         bool isFavorite = favorites.contains(landmark);

//         return Center(
//           child: Container(
//             width: 400,
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12.0),
//                   child: Stack(
//                     alignment: Alignment.bottomLeft,
//                     children: [
//                       Image.asset(
//                         landmark.imagePath,
//                         width: 400,
//                         height: 300,
//                         fit: BoxFit.cover,
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         color: Colors.black.withOpacity(0.7),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               landmark.name,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             // IconButton(
//                             //   icon: Icon(
//                             //     isFavorite ? Icons.favorite : Icons.favorite_border,
//                             //     color: Colors.white,
//                             //   ),
//                             //   onPressed: () {
//                             //     onFavoritePress(landmark);
//                             //   },
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class HistoryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('History Page'),
//     );
//   }
// }


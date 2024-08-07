import 'package:flutter/material.dart';
import 'my_creations_screen.dart';
import 'liked_songs_screen.dart';
import 'profile_screen.dart';
import 'create_screen.dart';
import 'discover_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundOfMeme',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    DiscoverScreen(),
    MyCreationsScreen(),
    CreateScreen(),
    LikedSongsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CustomLogo(),
            SizedBox(width: 10),
            Text(
              'SoundOfMeme',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: [
          _buildNavItem(Icons.home, 'Discover'),
          _buildNavItem(Icons.music_note, 'My Creations'),
          _buildNavItem(Icons.add_circle, 'Create', isSpecial: true),
          _buildNavItem(Icons.favorite, 'Liked Songs'),
          _buildNavItem(Icons.person, 'Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, {bool isSpecial = false}) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: isSpecial ? Colors.purple : null,
        size: isSpecial ? 40 : 24,
      ),
      activeIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.purple),
      ),
      label: label,
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class CustomLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.purple,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
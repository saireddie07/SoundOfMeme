import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../API/API.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'log_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCreationsScreen extends StatefulWidget {
  @override
  _MyCreationsScreenState createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends State<MyCreationsScreen> {
  List<Map<String, dynamic>> _userSongs = [];
  bool _isLoading = true;
  String? _token;
  AudioPlayer _audioPlayer = AudioPlayer();
  int _currentlyPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    bool isLoggedIn = await ApiService.isLoggedIn();
    if (isLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _fetchUserSongs();
    } else {
      setState(() {
        _isLoading = false;
        _token = null;
      });
    }
  }

  Future<void> _fetchUserSongs() async {
    try {
      final songs = await ApiService.getUserSongs();
      setState(() {
        _userSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user songs: $e');
      setState(() {
        _isLoading = false;
        _token = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Creations',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitWave(
          color: Colors.purple,
          size: 50.0,
        ),
      )
          : _token == null
          ? _buildLoginPrompt()
          : _buildCreationsContent(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Please log in to view your creations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(
              'Log In / Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ).then((_) => checkLoginStatus());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreationsContent() {
    return _userSongs.isEmpty
        ? Center(
      child: Text(
        'No songs created yet',
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    )
        : ListView.builder(
      itemCount: _userSongs.length,
      itemBuilder: (context, index) {
        final song = _userSongs[index];
        return _buildSongCard(song, index);
      },
    );
  }

  Widget _buildSongCard(Map<String, dynamic> song, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _currentlyPlayingIndex == index ? Colors.purple : Colors.transparent,
          width: 1,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),

        color: Colors.grey[900],
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song['image_url'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                  child: Icon(Icons.music_note, color: Colors.white),
                );
              },
            ),
          ),
          title: Text(
            song['song_name'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${song['likes']}',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.remove_red_eye, color: Colors.grey[400], size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${song['views']}',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Created: ${song['date_time']}',
                style: GoogleFonts.poppins(color: Colors.grey[400]),
              ),
            ],
          ),

          trailing: IconButton(
            icon: Icon(
              _currentlyPlayingIndex == index ? Icons.pause : Icons.play_arrow,
              color: Colors.purple,
            ),
            onPressed: () {
              _togglePlayPause(song['song_url'], index);
            },
          ),
          onTap: () {
            // Implement song details view or edit functionality
          },
        ),
      ),
    );
  }

  void _togglePlayPause(String url, int index) async {
    if (_currentlyPlayingIndex == index) {
      await _audioPlayer.pause();
      setState(() {
        _currentlyPlayingIndex = -1;
      });
    } else {
      if (_currentlyPlayingIndex != -1) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlayingIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
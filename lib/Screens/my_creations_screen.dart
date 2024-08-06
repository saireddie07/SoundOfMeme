import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../API/API.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyCreationsScreen extends StatefulWidget {
  @override
  _MyCreationsScreenState createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends State<MyCreationsScreen> {
  List<Map<String, dynamic>> _userSongs = [];
  bool _isLoading = true;
  AudioPlayer _audioPlayer = AudioPlayer();
  int _currentlyPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchUserSongs();
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child:
        SpinKitWave(
          color: Colors.purple,
          size: 50.0,
        ),)
          : _userSongs.isEmpty
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
      ),
    );
  }

  Widget _buildSongCard(Map<String, dynamic> song, int index) {
    return Card(
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
            Text(
              'Likes: ${song['likes']} | Views: ${song['views']}',
              style: GoogleFonts.poppins(color: Colors.grey[400]),
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
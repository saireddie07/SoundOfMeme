import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/GenerateSongButtonWidget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';



class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _genreController = TextEditingController();
  Map<String, dynamic>? _generatedSong;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    _genreController.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateSong() async {
    setState(() {
      _isLoading = true;
      _generatedSong = null;
    });
    _animationController.reset();

    final url = Uri.parse('http://143.244.131.156:8000/createcustom');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: json.encode({
          "title": _titleController.text,
          "lyric": _lyricsController.text,
          "genere": _genreController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _generatedSong = json.decode(response.body);
        });
        _animationController.forward();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate song. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please check your connection and try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _togglePlayPause() async {
    if (_generatedSong != null) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(_generatedSong!['song_url']));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
            'Create Your Song',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.purple.withOpacity(0.5),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: 'Song Title',
                      labelStyle: GoogleFonts.poppins(color: Colors.purple[200]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple[700]!, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple[400]!, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              )
              ),
              SizedBox(height: 16),
              TextField(
                controller: _lyricsController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Song Lyrics',
                  labelStyle: GoogleFonts.poppins(color: Colors.purple[200]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[400]!, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                  controller: _genreController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Song Genre',
                    labelStyle: GoogleFonts.poppins(color: Colors.purple[200]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[700]!, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[400]!, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                ),
              SizedBox(height: 24),
              // ... (rest of the build method)

              AnimatedGradientButton(
                isLoading: _isLoading,
                onPressed: _generateSong,
              ),

// ... (rest of the build method),
              SizedBox(height: 24),
              if (_isLoading)
                Center(
                  child: SpinKitWave(
                    color: Theme.of(context).primaryColor,
                    size: 50.0,
                  ),
                )
              else if (_generatedSong != null)
                SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generatedSong!['song_name'],
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Genre: ${_generatedSong!['tags'].join(', ')}'),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.red),
                              Text(' ${_generatedSong!['likes']}'),
                              SizedBox(width: 16),
                              Icon(Icons.remove_red_eye, color: Colors.blue),
                              Text(' ${_generatedSong!['views']}'),
                            ],
                          ),
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _generatedSong!['image_url'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: IconButton(
                              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                              onPressed: _togglePlayPause,
                              iconSize: 64,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


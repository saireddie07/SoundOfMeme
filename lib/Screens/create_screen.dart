import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Widgets/MusicWavePainter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/GenerateSongButtonWidget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../API/API.dart';
import 'log_in_screen.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _genreController = TextEditingController();
  Map<String, dynamic>? _generatedSong;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  List<String> _loadingMessages = [
    'Crafting your tune, hang tight!',
    'Recording vocals and instruments',
    'Mixing the tracks',
    'Fine-tuning the melody, almost there!',
    'Adding some cool beats, hold on!',
    "Please don't get angry, it's almost ready!",
    'Polishing the final track, stay tuned!',
    'Getting ready for the grand reveal!'
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

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
    _stopChangingMessages();
    super.dispose();
  }

  void _startChangingMessages() {
    _currentMessageIndex = 0;
    _messageTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  void _stopChangingMessages() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  Future<void> _generateSong() async {
    bool isLoggedIn = await ApiService.isLoggedIn();

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seems like you didn\'t log in. Please log in to create awesome songs.'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedSong = null;
    });
    _animationController.reset();
    _startChangingMessages();

    final url = Uri.parse('http://143.244.131.156:8000/createcustom');
    try {
      String? token = await ApiService.isLoggedIn() ? await SharedPreferences.getInstance().then((prefs) => prefs.getString('auth_token')) : null;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
      _stopChangingMessages();
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
              AnimatedGradientButton(
                isLoading: _isLoading,
                onPressed: _generateSong,
              ),
              SizedBox(height: 24),

              if (_isLoading)
                Column(
                  children: [
                    Center(
                      child: SpinKitWave(
                        color: Theme.of(context).primaryColor,
                        size: 50.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _loadingMessages[_currentMessageIndex],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else if (_generatedSong != null)
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          color: Colors.white.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _generatedSong!['song_name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Genre: ${_generatedSong!['tags'].join(', ')}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                    onPressed: _togglePlayPause,
                                    iconSize: 64,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  _generatedSong!['image_url'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(Icons.favorite, _generatedSong!['likes'].toString(), 'Likes'),
                                  _buildStatItem(Icons.remove_red_eye, _generatedSong!['views'].toString(), 'Views'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
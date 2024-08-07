import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../API/API.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class MusicWavePainter extends CustomPainter {
  final Color color;
  final int waveCount;
  final double animation;

  MusicWavePainter({required this.color, this.waveCount = 5, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final width = size.width / (waveCount * 2);
    final height = size.height;

    for (int i = 0; i < waveCount; i++) {
      final x = i * width * 2;
      final amplitude = height / 2 * (0.3 + 0.7 * sin((animation + i / waveCount) * 2 * pi));

      final path = Path()
        ..moveTo(x, height / 2)
        ..cubicTo(
            x + width / 2, height / 2 - amplitude,
            x + width / 2, height / 2 + amplitude,
            x + width, height / 2
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Map<String, dynamic>> _allSongs = [];
  bool _isLoading = true;
  AudioPlayer _audioPlayer = AudioPlayer();
  int _currentlyPlayingIndex = -1;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAllSongs();
  }

  Future<void> _fetchAllSongs() async {
    try {
      final songs = await ApiService.getAllSongs(page: _currentPage);
      setState(() {
        _allSongs.addAll(songs);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching all songs: $e');
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
          ? Center(
        child: SpinKitWave(
          color: Colors.purple,
          size: 50.0,
        ),
      )
          : _allSongs.isEmpty
          ? Center(
        child: Text(
          'No songs available',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      )
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _allSongs.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final song = _allSongs[index];
          return _buildSongCard(song, index);
        },
      ),
    );
  }

  Widget _buildSongCard(Map<String, dynamic> song, int index) {
    bool isPlaying = _currentlyPlayingIndex == index;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPlaying ? Colors.purple : Colors.grey,
          width:isPlaying ? 2 : 1,
        ),
      ),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    child: Image.network(
                      song['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: Icon(Icons.music_note, color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),
                  if (isPlaying)
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1),
                        duration: Duration(seconds: 7),
                        builder: (context, value, child) {
                          return CustomPaint(
                            painter: MusicWavePainter(
                              color: Colors.white.withOpacity(0.7),
                              animation: value,
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _togglePlayPause(song['song_url'], index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['song_name'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${song['likes']}',
                            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.grey[400], size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${song['views']}',
                            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
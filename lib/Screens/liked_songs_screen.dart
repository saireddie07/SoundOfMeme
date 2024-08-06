import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LikedSongsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('No songs liked yet',style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }
}

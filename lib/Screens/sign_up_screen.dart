import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../API/API.dart';
import 'log_in_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords don't match";
        _isLoading = false;
      });
      return;
    }

    try {
      final success = true;
      if (success) {
        _navigateToHome();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _googleSignUp() async {
    // Implement Google sign up logic here
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SoundOfMeme',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                _buildTextField(_nameController, 'Name', Icons.person),
                SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
                SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sign Up', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _googleSignUp,
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.white),
                  label: Text('Sign Up with Google', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.purple[200]),
        prefixIcon: Icon(icon, color: Colors.purple[400]),
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
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
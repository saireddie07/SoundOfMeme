import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class ApiService {
  static const String baseUrl = 'http://143.244.131.156:8000';
  static String? _token;

  //LOGIN
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      return _token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }


  //LOGOUT
  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }


  //ISLOGGEDIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token != null;
  }

  //USERDETAILS
  static Future<Map<String, dynamic>> getUserDetails() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }

    if (_token == null) {
      throw Exception('Not logged in');
    }

    final response = await http.get(
      Uri.parse('http://143.244.131.156:8000/user'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user details: ${response.body}');
    }
  }


  //GETUSERSONGS
  static Future<List<Map<String, dynamic>>> getUserSongs({int page = 1}) async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }

    if (_token == null) {
      throw Exception('Not logged in');
    }

    final response = await http.get(
      Uri.parse('http://143.244.131.156:8000/usersongs?page=$page'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String,dynamic> data = json.decode(response.body);
      final List<dynamic> songs = data['songs'];
      return songs.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get user songs: ${response.body}');
    }
  }

  //GOOGLELOGIN
  static Future<String?> googleLogin(String name, String email, String picture) async {
    final response = await http.post(
      Uri.parse('$baseUrl/googlelogin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'picture': picture,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      return _token;
    } else {
      throw Exception('Failed to login with Google: ${response.body}');
    }
  }

}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:evolv_mobile/config/app_config.dart';
import 'package:evolv_mobile/dto/user_info_dto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = "https://evolv-spring.onrender.com/evolv";
  static final String baseUrl = AppConfig.apiUrl; //"http://192.168.31.71:8080/evolv";
  // If using real device: replace with your host IP

  Future<(bool, String, UserDTO?)> login(String username, String password) async {
    debugPrint("Attempting login for user: $username");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Parse into UserDTO
        final user = UserDTO.fromJson(body);

        // Save user in SharedPreferences (as JSON)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("authToken", user.token);
        await prefs.setString("userInfo", jsonEncode(user.toJson()));

        debugPrint(" Login Successful: ${user.userName}");
        return (true, "Welcome ${user.shortName}", user);
      } else {
        String message = "Login failed";
        try {
          final body = jsonDecode(response.body);
          if (body["message"] != null) {
            message = body["message"];
          }
        } catch (_) {}
        return (false, message, null);
      }
    } on SocketException {
      return (false, "No internet connection", null);
    } on TimeoutException {
      return (false, "Request timed out", null);
    } on FormatException {
      return (false, "Invalid server response", null);
    } catch (e) {
      return (false, "Unexpected error: $e", null);
    }
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    return response.statusCode == 200;
  }

  Future<UserDTO?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("authToken");

    final response = await http.get(
      Uri.parse("$baseUrl/api/users/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return UserDTO.fromJson(data);
    } else {
      print('Failed to fetch profile: ${response.statusCode}');
      return null;
    }
  }
}

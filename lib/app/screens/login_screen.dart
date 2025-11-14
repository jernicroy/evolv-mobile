import 'dart:convert';

import 'package:evolv_mobile/app/theme/app_theme.dart';
import 'package:evolv_mobile/core/services/app_routes.dart';
import 'package:evolv_mobile/core/services/login_service.dart';
import 'package:evolv_mobile/core/utils/app_notifications.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/dto/user_info_dto.dart';
import '../../core/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  UserDTO? user;
  bool _loading = false;
  bool biometricAvailable = false;
  final LocalAuthentication auth = LocalAuthentication();
  MaterialColor primaryColor = AppTheme.primaryColor;
  MaterialColor primarySubColor = AppTheme.primarySubColor;
  MaterialAccentColor primaryColorAccent = AppTheme.primaryColorAccent;
  Color backgroundColor = AppTheme.backgroundColor;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool available = await auth.canCheckBiometrics;
      setState(() {
        biometricAvailable = available;
      });
    } catch (e) {
      debugPrint("Error checking biometric availability: $e.toString()");
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    final (success, message, user) = await _apiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (success && user != null) {
      LoggedInUser.user = user;

      AppNotifications.showToast('Welcome ${user.shortName}');

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: user.shortName,
      );
    } else {
       AppNotifications.showAlertDialog(
        context,
        "Login Failed!",
        message,
      );

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(message)));
    }

    debugPrint("Login result: $message");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Text(
                "Welcome to",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColorAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // App Logo
              Image.asset(
                "assets/images/banner/evolv-banner-mobile.png",
                height: 100,
              ),
              const SizedBox(height: 20),

              Text(
                "Sign in to continue",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primarySubColor[700],
                ),
              ),
              const SizedBox(height: 40),

              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: backgroundColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Login",
                          style: TextStyle(
                            color: backgroundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Spacer(),
              if (biometricAvailable)
                Column(
                  children: [
                    Text(
                      'or',
                      style: TextStyle(fontSize: 18, color: primarySubColor),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: _loading ? null : _biometricAuthentication,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor[50],
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor[200]!),
                        ),
                        child: _loading
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.fingerprint,
                                color: primaryColor[600],
                                size: 47,
                              ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Login with Biometrics',
                      style: TextStyle(fontSize: 18, color: primaryColor[600]),
                    ),
                    SizedBox(height: 25),
                  ],
                ),

              // Footer
              Text(
                "© 2025 Evolv Mobile App",
                style: TextStyle(color: primarySubColor[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _biometricAuthentication() async {
    debugPrint("Biometric authentication tapped");
    await _loadUserFromPrefs();
    if (user == null) {
      return;
    }
    if (!biometricAvailable) {
      if (!mounted) return;
       AppNotifications.showAlertDialog(
        context,
        "Unable to Authenticate",
        "Biometric authentication not available on this device.",
      );
      return;
    }

    try {
      bool authenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to Evolve Home',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!mounted) return;

      if (authenticate) {
        AppNotifications.showToast('Welcome ${user?.shortName}');

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: user?.shortName,
        );
      }
    } catch (e) {
      print(e.toString());
      AppNotifications.showAlertDialog(
        context,
        "Unable to Authenticate",
        e.toString(),
      );

    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("userInfo");

    if (userJson == null) {
      if (!mounted) return;

      AppNotifications.showAlertDialog(
        context,
        "Session Not Available",
        "Please login first to access Evolve Home.",
        onConfirm: () {
          return;
        },
      );
      return;
    }

    setState(() {
      user = UserDTO.fromJson(jsonDecode(userJson));
      _loading = false;
    });
  }
}

import 'package:evolv_mobile/services/app_routes.dart';
import 'package:evolv_mobile/services/login_service.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _loading = false;

Future<void> _login() async {
  setState(() => _loading = true);

  final (success, message, user) = await _apiService.login(
    _usernameController.text,
    _passwordController.text,
  );

  setState(() => _loading = false);

  if (success && user != null) {
    LoggedInUser.user = user;

    // Show success toast/snackbar with shortName
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Welcome ${user.shortName}!")),
    );

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: user.shortName,
    );
  } else {
    // Show error toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" $message")),
    );
  }

  debugPrint("⬅️ Login result: $message");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}

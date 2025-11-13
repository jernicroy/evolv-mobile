import 'package:evolv_mobile/services/app_routes.dart';
import 'package:evolv_mobile/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _loading = false;
  bool biometricAvailable = false;
  final LocalAuthentication auth = LocalAuthentication();

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome ${user.shortName}!")),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: user.shortName,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    debugPrint("Login result: $message");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: Colors.blueAccent,
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
                  color: Colors.grey[700],
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
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Spacer(),
              if(biometricAvailable)
                Column(
                  children: [
                    Text('or', style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey
                    ),),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: _loading ? null : _biometricAuthentication,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: _loading
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              )
                            : Icon(
                                Icons.fingerprint,
                                color: Colors.blue[600],
                                size: 47,
                              ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Login with Biometrics',
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                    SizedBox(height: 10),
                  ],
                ),

              // Footer (optional)
              Text(
                "© 2025 Evolv Mobile App",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _biometricAuthentication() async {
    debugPrint("Biometric authentication tapped");
    if(!biometricAvailable){
      return;
    }
    setState(() {
      _loading = true;
    });

    try{
      bool authenticate = await auth.authenticate(localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      String dummyUserName = "Jernic Roy - Biometric";
      if (!mounted) return;

      if(authenticate){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome $dummyUserName')),
        );
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: dummyUserName,
        );
      }
    } catch(e){
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}

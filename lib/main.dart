import 'package:evolv_mobile/services/app_routes.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evolv Home',
      initialRoute: '/',
       routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.home: (context) => HomeScreen(),
      },
    );
  }
}

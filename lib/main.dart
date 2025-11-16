import 'package:evolv_mobile/app/theme/app_themes.dart';
import 'package:evolv_mobile/core/services/app_routes.dart';
import 'package:flutter/material.dart';
import 'app/screens/login_screen.dart';
import 'app/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      title: 'Evolv Home',
      initialRoute: '/',
       routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.home: (context) => HomeScreen(
          onThemeChanged: toggleTheme
        ),
      },
    );
  }
}

import 'dart:convert';

import 'package:evolv_mobile/dto/user_info_dto.dart';
import 'package:evolv_mobile/services/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  UserDTO? user;
  int _selectedIndex = 0;
  bool _loading = true;

  final List<Widget> _pages = [
    Center(child: Text("Me")),        // Me tab
    Center(child: Text("Family")),    // Family tab
    Container(),                      // Placeholder for Add roll-up
    Center(child: Text("Settings")),  // Settings tab
  ];

  @override
  void initState() {
    super.initState();
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("userInfo");
    if (userJson == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    setState(() {
      user = UserDTO.fromJson(jsonDecode(userJson));
      _loading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddMenu();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Add Medication'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Add Medication Page
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Add Prescription'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Add Prescription Page
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Evolve Home | ${user!.shortName}"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "Family"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
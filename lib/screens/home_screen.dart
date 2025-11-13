import 'dart:convert';

import 'package:evolv_mobile/config/app_config.dart';
import 'package:evolv_mobile/dto/user_info_dto.dart';
import 'package:evolv_mobile/services/app_routes.dart';
import 'package:evolv_mobile/services/login_service.dart';
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
  Color primaryColor = const Color.fromARGB(255, 255, 243, 255);
  
  // Titles for top panel based on active tab
  final List<String> _titles = [
    "My Profile",
    "Family Members",
    "",
    "Settings",
  ];

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
      if (!mounted) return;
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
      // appBar: AppBar(
      //   title: Text("Evolve Home | ${user!.shortName}"),
      // ),
      backgroundColor: primaryColor,
      body: Column(
        children: [
          // 🔹 Static Top Panel
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Static app name
                  const Text(
                    AppConfig.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Center: Dynamic screen title
                  Expanded(
                    child: Center(
                      child: Text(
                        _titles[_selectedIndex].isEmpty
                            ? ""
                            : _titles[_selectedIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Right: User dropdown menu
                  PopupMenuButton<String>(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    offset: const Offset(0, 36),
                    padding: EdgeInsets.zero, // removes extra outer padding
                    onSelected: (value) {
                      if (value == 'role') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Role: ${user?.role ?? "N/A"}')),
                        );
                      } else if (value == 'change_password') {
                        // Navigate to Change Password Page
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      } else if (value == 'logout') {
                        if (!mounted) return;
                        LoggedInUser.logout();
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.clear();
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        });
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 32,
                        value: 'role',
                        child: Row(
                          children: [
                            const Icon(Icons.badge, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              'Role: ${user?.role ?? "N/A"}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 6),
                      const PopupMenuItem(
                        height: 32,
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('Change Password'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 6),
                      const PopupMenuItem(
                        height: 32,
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.login_outlined, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle, color: Colors.white, size: 26),
                        const SizedBox(width: 6),
                        Text(
                          user?.shortName ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
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
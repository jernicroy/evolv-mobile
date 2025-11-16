import 'dart:convert';

import 'package:evolv_mobile/app/config/app_config.dart';
import 'package:evolv_mobile/app/screens/family/family_list.dart';
import 'package:evolv_mobile/core/dto/user_info_dto.dart';
import 'package:evolv_mobile/core/services/api_service.dart';
import 'package:evolv_mobile/core/services/app_routes.dart';
import 'package:evolv_mobile/core/utils/app_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onThemeChanged});
  final VoidCallback? onThemeChanged;

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  UserDTO? user;
  int _selectedIndex = 0;
  bool _loading = true;
  final _apiService = ApiService();

  // Color primaryColor = const Color.fromARGB(255, 252, 247, 252);
  
  // Titles for top panel based on active tab
  final List<String> _titles = [
    "My Profile",
    "Family Members",
    "",
    "Settings",
  ];

  final List<Widget> _pages = [
    Center(child: Text("Me")),        // Me tab
    FamilyListScreen(),               // Family tab
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
      AppNotifications.showAlertDialog(
        context,
        "Session Not Available",
        "Please login first to access Evolve Home.",
        onConfirm: () {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
      );
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
      body: Column(
        children: [
          // Static Top Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Static app name
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Right: User dropdown menu
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    offset: const Offset(0, 36),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'role') {
                        AppNotifications.showToast("Role: ${user?.role ?? "N/A"}");
                      } else if (value == 'change_password') {
                        // Navigate to Change Password Page
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      } else if (value == 'logout') {
                        if (!mounted) return;
                        _apiService.logout(context);
                      } else if (value == 'theme_change') {
                        if (widget.onThemeChanged != null) {
                          widget.onThemeChanged!();
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 32,
                        value: 'theme_change',
                        child: Row(
                          children: [
                            Icon(Icons.color_lens_outlined),
                            const SizedBox(width: 6),
                            Text(
                              'Switch Theme',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 6),
                      PopupMenuItem(
                        height: 32,
                        value: 'role',
                        child: Row(
                          children: [
                            Icon(Icons.badge),
                            const SizedBox(width: 6),
                            Text(
                              'Role: ${user?.role ?? "N/A"}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 6),
                      PopupMenuItem(
                        height: 32,
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline),
                            SizedBox(width: 6),
                            Text('Change Password'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 6),
                      PopupMenuItem(
                        height: 32,
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.login_outlined),
                            SizedBox(width: 6),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        Icon(Icons.account_circle, size: 26),
                        const SizedBox(width: 6),
                        Text(
                          user?.shortName ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
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
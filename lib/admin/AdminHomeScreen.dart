
import 'package:clothing_shop/admin/AdminAboutScreen.dart';
import 'package:clothing_shop/admin/AdminProfileManageUsersScreen.dart';
import 'package:clothing_shop/admin/AdminShortsScreen.dart';
import 'package:clothing_shop/admin/AdminSkinnyArmcutScreen.dart';
import 'package:clothing_shop/admin/AdminTShirtScreen.dart';
import 'package:flutter/material.dart';
// Powerd by CP Fusion 
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Controls whether the navigation menu dropdown is expanded or collapsed
  bool _isMenuOpen = false;

  // Selected item title for content display
  String _selectedSection = "T-shirt";

  final List<String> _menuItems = [
    "T-shirt",
    "Skinny & Armcut",
    "Short & Bottom",
    "Profile",
    "About",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image & Dark Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background7.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Title
                  const Center(
                    child: Text(
                      "CLOTHING SHOP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Admin Home Subtitle
                  const Center(
                    child: Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Menu Hamburger Icon Toggle Button (≡)
                  IconButton(
                    icon: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = !_isMenuOpen;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Stack to overlay dropdown menu over main dashboard content
                  Expanded(
                    child: Stack(
                      children: [
                        // Dashboard Content Placeholder
                        Container(
                          width: double.infinity,
                          height: 0 ,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 200),
                              Text(
                                "Manage details, inventory, or settings here.",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated Dropdown Menu Panel (Triggered by ≡)
                        if (_isMenuOpen)
                          Positioned(
                            top: 0,
                            left: 0,
                            width: 170, // Fixed width matching wireframe style
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white54, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _menuItems.map((item) {
                                  final bool isSelected = _selectedSection == item;
                                  return Column(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 0.0,
                                        ),
                                        title: Text(
                                          item,
                                          style: TextStyle(
                                            color: isSelected ? Colors.blueAccent : Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                        onTap: () {
                                      setState(() {
                                        _selectedSection = item;
                                        _isMenuOpen = false; // Close menu
                                      });

                                      // Handle navigation based on selected menu item
                                      if (item == "T-shirt") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AdminTShirtScreen(),
                                          ),
                                        );
                                      } else if(item == "Skinny & Armcut") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder:(context) => const AdminSkinnyArmcutScreen())
                                          );

                                      } else if(item == "Short & Bottom") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AdminShortsScreen()),
                                        );
                                      } else if(item == "Profile"){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AdminProfileManageUsersScreen()),
                                          );
                                      } else if(item == "About"){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const AdminAboutScreen()),
                                        );
                                      }

                                    },
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: Colors.white24,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
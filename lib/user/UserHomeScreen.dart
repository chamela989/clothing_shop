import 'package:clothing_shop/user/UserAboutScreen.dart';
import 'package:clothing_shop/user/UserCartScreen.dart';
import 'package:clothing_shop/user/UserFeedbackScreen.dart';
import 'package:clothing_shop/user/UserProfileScreen.dart';
import 'package:clothing_shop/user/UserShortsBottomScreen.dart';
import 'package:clothing_shop/user/UserSkinnyArmcutScreen.dart';
import 'package:clothing_shop/user/UserTShirtScreen.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Global Background Image & Dark Gradient Overlay for Main Home Page
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
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // 2. Foreground Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Title
                  const Text(
                    "CLOTHING SHOP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- SHOP SECTION ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Shop",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 Shop Cards (T-Shirt, Skinney & Armcut, Shorts & Bottom)
                  SizedBox(
                    height: 120,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            title: "T-Shirt",
                            imagePath: 'assets/images/Background9.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=> const UserTShirtScreen()),
                              );

                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCategoryCard(
                            title: "Skinney\n& Armcut",
                            imagePath: 'assets/images/Background12.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=> const UserSkinnyArmcutScreen()),
                                );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded( // Powerd by CP Fusion
                          child: _buildCategoryCard(
                            title: "Shorts\n& Bottom",
                            imagePath: 'assets/images/Background13.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=> const UserShortsBottomScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- PROFILE SECTION ---
                  _buildSectionCard(
                    title: "Profile",
                    imagePath: 'assets/images/Background14.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const UserProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- CART SECTION ---
                  _buildSectionCard(
                    title: "Cart",
                    imagePath: 'assets/images/Background17.png',
                    onTap: () {
                      Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=> const UserCartScreen()),
                              );
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- ABOUT SECTION ---
                  _buildSectionCard(
                    title: "About",
                    imagePath: 'assets/images/Background15.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const UserAboutScreen()),
                        );
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- FEEDBACK SECTION ---
                  _buildSectionCard(
                    title: "Feed Back",
                    imagePath: 'assets/images/Background7.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>const UserFeedbackScreen()),
                        );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget for small Shop cards (T-Shirt, Skinney, Shorts) with background images
  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white30, width: 1),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container( // Powerd by CP Fusion 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.5), // Dark overlay for text readability
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for large view cards (Profile, Cart, About, Feed Back) with background images
  Widget _buildSectionCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white30, width: 1),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.4), // Dark overlay for contrast
              ),
              alignment: Alignment.center,
              child: Text(
                "View $title",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
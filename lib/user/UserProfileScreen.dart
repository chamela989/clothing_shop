import 'dart:convert';
import 'package:clothing_shop/user/UserProfileEditScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, this.userId = 'current_user_id'}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fetch registration details directly from Firestore 'users' collection
  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dark Background Image & Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background7.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.70)),
          ),

          // 2. Main Content
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header Titles matching wireframe
                          const Text(
                            'CLOTHING SHOP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Profile Display Box (Image or Placeholder) matching wireframe
                          Container(
                            width: 120,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white70, width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _userData != null &&
                                    _userData!['imageBase64'] != null &&
                                    (_userData!['imageBase64'] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.memory(
                                      base64Decode(_userData!['imageBase64']),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline,
                                    color: Colors.white54,
                                    size: 55,
                                  ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Add',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 35),

                          // Read-Only Display Fields matching wireframe
                          _buildProfileRow('Name', _userData?['name'] ?? 'Not set'),
                          const SizedBox(height: 18),
                          _buildProfileRow('Email', _userData?['email'] ?? 'Not set'),
                          const SizedBox(height: 18),
                          _buildProfileRow('Mobile Number', _userData?['mobile'] ?? 'Not set'),
                          const SizedBox(height: 18),
                          _buildProfileRow('ID', widget.userId),
                          const SizedBox(height: 18),
                          _buildProfileRow(
                            'Password',
                            _userData?['password'] != null ? '••••••••' : 'Not set',
                          ),

                          const SizedBox(height: 50),

                          // Edit Button matching wireframe
                          SizedBox(
                            width: 180,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                   builder: (context) => UserProfileEditScreen(
                                     userId: widget.userId,
                                     initialData: _userData,
                                    ),
                                  ),
                                );

                                  // Reload profile if data was saved
                                 if (result == true) {
                                   _loadUserProfile();
                                  }
                               },
                              child: const Text(
                                'Edit',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper widget to display field labels with dotted underlines
  Widget _buildProfileRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label :',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white24,
        ),
      ],
    );
  }
}
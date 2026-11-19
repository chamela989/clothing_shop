import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileEditScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? initialData;

  const UserProfileEditScreen({
    Key? key,
    this.userId = 'current_user_id',
    this.initialData,
  }) : super(key: key);

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String? _imageBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    _mobileController = TextEditingController(text: widget.initialData?['mobile'] ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _imageBase64 = widget.initialData?['imageBase64'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Image Picker Logic (Converts selected image to Base64 String)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  // Save profile updates back to Firestore 'users' collection
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check password matching if user tries to update password
    if (_newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Password and Confirm Password do not match!')),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'imageBase64': _imageBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_newPasswordController.text.isNotEmpty) {
        updateData['password'] = _newPasswordController.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set(updateData, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context, true); // Return true so UserProfileScreen reloads data
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dark Background Image & Overlay matching wireframe style
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background5.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.70)),
          ),

          // 2. Form Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
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
                      'Profile\nEdit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Picker Box matching wireframe
                    InkWell(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white70, width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _imageBase64 != null && _imageBase64!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.memory(
                                      base64Decode(_imageBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Editable Fields matching wireframe fields
                    _buildInputField('Name', _nameController),
                    const SizedBox(height: 14),
                    _buildInputField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildInputField('Mobile Number', _mobileController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildReadOnlyField('ID', widget.userId),
                    const SizedBox(height: 14),
                    _buildInputField('Current Password', _currentPasswordController, isObscure: true),
                    const SizedBox(height: 14),
                    _buildInputField('New Password', _newPasswordController, isObscure: true),
                    const SizedBox(height: 14),
                    _buildInputField('Confirm Password', _confirmPasswordController, isObscure: true),

                    const SizedBox(height: 35),

                    // Save Button matching wireframe
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
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Save',
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

  // Text Form Field Builder with Wireframe Line Style
  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(
                '$label :',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: isObscure,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amberAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label :',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
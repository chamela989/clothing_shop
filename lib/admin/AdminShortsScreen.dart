import 'dart:convert';
import 'dart:io';
import 'package:clothing_shop/admin/AdminShortsDeleteScreen.dart';
import 'package:clothing_shop/admin/AdminShortsUpdateScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminShortsScreen extends StatefulWidget {
  const AdminShortsScreen({Key? key}) : super(key: key);

  @override
  State<AdminShortsScreen> createState() => _AdminShortsScreenState();
}

class _AdminShortsScreenState extends State<AdminShortsScreen> {
  // Text Controllers for input fields matching the wireframe
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Dropdown value for availability
  String _selectedAvailable = 'In Stock';
  final List<String> _availabilityOptions = ['In Stock', 'Out of Stock'];

  // Active bottom tab index (0: Add, 1: Update, 2: Delete)
  int _bottomNavIndex = 0;

  bool _isLoading = false;

  // Image picking variables
  File? _imageFile;
  Uint8List? _webImageBytes; // For Flutter Web support
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from device gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          var bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Function to save Shorts & Bottom details and Base64 image to Firestore
  Future<void> _addShortsToFirestore() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Item Name and Price')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageBase64 = '';

      // Convert selected image to Base64 string if available
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      } else if (_webImageBytes != null) {
        imageBase64 = base64Encode(_webImageBytes!);
      }

      // Save Data & Image String to Firestore 'shorts_bottom' collection
      await FirebaseFirestore.instance.collection('shorts_bottom').add({
        'name': _nameController.text.trim(),
        'material': _materialController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'available': _selectedAvailable,
        'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shorts & Bottom added successfully to Database!')),
      );

      // Clear input fields and image preview
      _nameController.clear();
      _materialController.clear();
      _priceController.clear();
      setState(() {
        _imageFile = null;
        _webImageBytes = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
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
          // 1. Background Image & Dark Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background4.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          // 2. Main Form Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Titles
                        const Text(
                          'CLOTHING SHOP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Shorts\n&\nBottom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Image Picker Box container with preview
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 90,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[900],
                              image: _imageFile != null
                                  ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                  : (_webImageBytes != null
                                      ? DecorationImage(image: MemoryImage(_webImageBytes!), fit: BoxFit.cover)
                                      : null),
                            ),
                            child: (_imageFile == null && _webImageBytes == null)
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: Colors.white70, size: 28),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Input Fields
                        _buildInputField('T-Shirt Name', _nameController),
                        _buildInputField('T-Shirt Material', _materialController),
                        _buildInputField('Price', _priceController, keyboardType: TextInputType.number),

                        const SizedBox(height: 25),

                        // Available Dropdown Selector
                        Row(
                          children: [
                            const Text(
                              'Available',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white70),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black54,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedAvailable,
                                    dropdownColor: Colors.grey[900],
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    items: _availabilityOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedAvailable = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Form Add Button
                        SizedBox(
                          width: 190,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _isLoading ? null : _addShortsToFirestore,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    'Add',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom 3-Button Action Bar (Add / Update / Delete)
                Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
                  ),
                  child: Row(
                    children: [
                      _buildBottomNavButton('Add', 0),
                      _buildBottomNavButton('Update', 1),
                      _buildBottomNavButton('Delete', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54, style: BorderStyle.solid),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton(String title, int index) {
    bool isSelected = _bottomNavIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _bottomNavIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (Context) => const AdminShortsUpdateScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=> const AdminShortsDeleteScreen()),
              );
            
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[900] : Colors.transparent,
            border: Border(
              right: index < 2 ? BorderSide(color: Colors.grey[800]!, width: 1) : BorderSide.none,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.amberAccent : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
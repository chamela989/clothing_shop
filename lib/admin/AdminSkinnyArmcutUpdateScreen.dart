import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminSkinnyArmcutUpdateScreen extends StatefulWidget {
  const AdminSkinnyArmcutUpdateScreen({Key? key}) : super(key: key);

  @override
  State<AdminSkinnyArmcutUpdateScreen> createState() => _AdminSkinnyArmcutUpdateScreenState();
}

class _AdminSkinnyArmcutUpdateScreenState extends State<AdminSkinnyArmcutUpdateScreen> {
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

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Header Titles
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'CLOTHING SHOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Skinny\n& \nArmcut',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Real-time List of Skinny & Armcut Items from Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('skinny_armcut')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(// Powerd by CP Fusion 
                          child: Text(
                            'No Skinny & Armcut items found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;

                          String name = data['name'] ?? 'No Name';
                          String material = data['material'] ?? '';
                          dynamic price = data['price'] ?? 0.0;
                          String imageBase64 = data['imageBase64'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              border: Border.all(color: Colors.white54, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 1. Image Column
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.white54)),
                                    ),
                                    child: imageBase64.isNotEmpty
                                        ? Image.memory(
                                            base64Decode(imageBase64),
                                            fit: BoxFit.cover,
                                            height: 60,
                                            width: 70,
                                          )
                                        : const Icon(Icons.image_not_supported, color: Colors.white54, size: 30),
                                  ),

                                  // 2. Details Column
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Material: $material',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // 3. Price Column
                                  Container(
                                    width: 70,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: Colors.white54),
                                        right: BorderSide(color: Colors.white54),
                                      ),
                                    ),
                                    child: Text(
                                      'Rs.$price',
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // 4. Clickable Edit Icon Column (Replaces Quantity)
                                  InkWell(
                                    onTap: () {
                                      _showFullUpdateDialog(context, docId, data);
                                    },
                                    child: Container(
                                      width: 60,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.edit, color: Colors.blueAccent, size: 22),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Full Edit Form Popup Dialog
  void _showFullUpdateDialog(BuildContext parentContext, String docId, Map<String, dynamic> currentData) {
    final scaffoldMessenger = ScaffoldMessenger.of(parentContext);

    final TextEditingController nameController = TextEditingController(text: currentData['name'] ?? '');
    final TextEditingController materialController = TextEditingController(text: currentData['material'] ?? '');
    final TextEditingController priceController = TextEditingController(text: currentData['price']?.toString() ?? '');

    String selectedAvailable = currentData['available'] ?? 'In Stock';
    final List<String> availabilityOptions = ['In Stock', 'Out of Stock'];

    File? newImageFile;
    Uint8List? newWebImageBytes;
    final ImagePicker picker = ImagePicker();
    String existingBase64 = currentData['imageBase64'] ?? '';

    bool isUpdating = false;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickNewImage() async {
              final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                if (kIsWeb) {
                  var bytes = await pickedFile.readAsBytes();
                  setDialogState(() {
                    newWebImageBytes = bytes;
                  });
                } else {
                  setDialogState(() {
                    newImageFile = File(pickedFile.path);
                  });
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.black.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white54, width: 1),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'CLOTHING SHOP',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Skinny & Armcut',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),

                    // Image Picker / Preview Box
                    GestureDetector(
                      onTap: pickNewImage,
                      child: Container(
                        width: 120,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[900],
                          image: newImageFile != null
                              ? DecorationImage(image: FileImage(newImageFile!), fit: BoxFit.cover)
                              : (newWebImageBytes != null
                                  ? DecorationImage(image: MemoryImage(newWebImageBytes!), fit: BoxFit.cover)
                                  : (existingBase64.isNotEmpty
                                      ? DecorationImage(image: MemoryImage(base64Decode(existingBase64)), fit: BoxFit.cover)
                                      : null)),
                        ),
                        child: (newImageFile == null && newWebImageBytes == null && existingBase64.isEmpty)
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.white70, size: 24),
                                  SizedBox(height: 4),
                                  Text('Update', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap image to change', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 20),

                    // Input Fields
                    _buildPopupInputField('Item Name', nameController),
                    _buildPopupInputField('Material', materialController),
                    _buildPopupInputField('Price', priceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 15),

                    // Available Dropdown
                    Row(
                      children: [
                        const Text('Available', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white70),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black54,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedAvailable,
                                dropdownColor: Colors.grey[900],
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                items: availabilityOptions.map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value));
                                }).toList(),
                                onChanged: (newValue) {
                                  setDialogState(() {
                                    selectedAvailable = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Bottom Update Button
                    SizedBox(
                      width: 160,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: isUpdating
                            ? null
                            : () async {
                                setDialogState(() {
                                  isUpdating = true;
                                });

                                try {
                                  String updatedBase64 = existingBase64;
                                  if (newImageFile != null) {
                                    List<int> imageBytes = await newImageFile!.readAsBytes();
                                    updatedBase64 = base64Encode(imageBytes);
                                  } else if (newWebImageBytes != null) {
                                    updatedBase64 = base64Encode(newWebImageBytes!);
                                  }

                                  await FirebaseFirestore.instance.collection('skinny_armcut').doc(docId).update({
                                    'name': nameController.text.trim(),
                                    'material': materialController.text.trim(),
                                    'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                                    'available': selectedAvailable,
                                    'imageBase64': updatedBase64,
                                  });

                                  Navigator.pop(dialogContext);
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(content: Text('Item updated successfully!')),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                } finally {
                                  setDialogState(() {
                                    isUpdating = false;
                                  });
                                }
                              },
                        child: isUpdating
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Update',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopupInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
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
}
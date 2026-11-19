import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSkinnyArmcutDeleteScreen extends StatefulWidget {
  const AdminSkinnyArmcutDeleteScreen({Key? key}) : super(key: key);

  @override
  State<AdminSkinnyArmcutDeleteScreen> createState() => _AdminSkinnyArmcutDeleteScreenState();
}

class _AdminSkinnyArmcutDeleteScreenState extends State<AdminSkinnyArmcutDeleteScreen> {
  // Function to show confirmation and delete item from Firestore safely
  void _confirmAndDelete(BuildContext parentContext, String docId, String itemName) {
    final scaffoldMessenger = ScaffoldMessenger.of(parentContext);

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Delete Item', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete "$itemName"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog first
                try {
                  await FirebaseFirestore.instance.collection('skinny_armcut').doc(docId).delete();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Item deleted successfully!')),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
                      SizedBox(height: 8),
                      Text(
                        'Skinny\n& \nArmcut',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        return const Center(
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
                          String available = data['available'] ?? 'In Stock';
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
                                    width: 75,
                                    padding: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.white54)),
                                    ),
                                    child: imageBase64.isNotEmpty
                                        ? Image.memory(
                                            base64Decode(imageBase64),
                                            fit: BoxFit.cover,
                                            height: 55,
                                            width: 65,
                                          )
                                        : const Icon(Icons.image_not_supported, color: Colors.white54, size: 26),
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
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Material: $material',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // 3. Price Column
                                  Container(
                                    width: 65,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // 4. Status/Quantity Column
                                  Container(
                                    width: 70,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: Colors.white54),
                                      ),
                                    ),
                                    child: Text(
                                      available,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // 5. Delete Icon Column
                                  InkWell(
                                    onTap: () {
                                      _confirmAndDelete(context, docId, name);
                                    },
                                    child: Container(
                                      width: 55,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 24,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
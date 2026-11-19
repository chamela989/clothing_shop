import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clothing_shop/user/UserCartScreen.dart';

class UserShortsBottomScreen extends StatefulWidget {
  const UserShortsBottomScreen({Key? key}) : super(key: key);

  @override
  State<UserShortsBottomScreen> createState() => _UserShortsBottomScreenState();
}

class _UserShortsBottomScreenState extends State<UserShortsBottomScreen> {
  final Set<String> _selectedItemIds = {};
  bool _isSavingToCart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Background3.png as per design standard) & Dark Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background3.png'),
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
                // Header Titles matching wireframe
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
                        'Shorts\n&\nBottom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Real-time List of Shorts & Bottom Products from Firestore collection 'shorts_bottom'
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('shorts_bottom')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No items available in Shorts & Bottom right now.',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                            textAlign: TextAlign.center,
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
                          String quantityOrType = data['quantity'] ?? data['type'] ?? data['fit'] ?? '';
                          dynamic price = data['price'] ?? 0.0;
                          String imageBase64 = data['imageBase64'] ?? '';

                          bool isSelected = _selectedItemIds.contains(docId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              border: Border.all(
                                color: isSelected ? Colors.amberAccent : Colors.white54,
                                width: isSelected ? 1.5 : 1,
                              ),
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
                                            'Mat: $material | Info: $quantityOrType',
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

                                  // 4. Quantity Status Column
                                  Container(
                                    width: 70,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.white54)),
                                    ),
                                    child: Text(
                                      data['available'] ?? 'In Stock',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // 5. Selection Checkbox Column
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedItemIds.remove(docId);
                                        } else {
                                          _selectedItemIds.add(docId);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: Colors.amberAccent,
                                        checkColor: Colors.black,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedItemIds.add(docId);
                                            } else {
                                              _selectedItemIds.remove(docId);
                                            }
                                          });
                                        },
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

                // Bottom Cart Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
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
                      onPressed: _isSavingToCart
                          ? null
                          : () async {
                              if (_selectedItemIds.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select at least one item to add to Cart!')),
                                );
                                return;
                              }

                              setState(() {
                                _isSavingToCart = true;
                              });

                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              try {
                                const String userId = 'current_user_id';
                                
                                // Fetch existing items from cart so T-Shirts & Skinny items are preserved
                                DocumentSnapshot cartDoc = await FirebaseFirestore.instance.collection('carts').doc(userId).get();
                                List<String> existingIds = [];
                                if (cartDoc.exists && cartDoc.data() != null) {
                                  Map<String, dynamic> data = cartDoc.data() as Map<String, dynamic>;
                                  existingIds = List<String>.from(data['itemIds'] ?? []);
                                }

                                // Combine with newly selected Shorts items without duplicates
                                Set<String> combinedIds = {...existingIds, ..._selectedItemIds};

                                await FirebaseFirestore.instance.collection('carts').doc(userId).set({
                                  'itemIds': combinedIds.toList(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserCartScreen(selectedItemIds: combinedIds.toList()),
                                    ),
                                  );
                                }
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('Error saving to cart: $e')),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSavingToCart = false;
                                  });
                                }
                              }
                            },
                      child: _isSavingToCart
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Cart',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                    ),
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
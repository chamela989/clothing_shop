import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clothing_shop/user/UserCheckoutScreen.dart'; // Make sure this import matches your file path

class UserCartScreen extends StatefulWidget {
  final List<String>? selectedItemIds;

  const UserCartScreen({Key? key, this.selectedItemIds}) : super(key: key);

  @override
  State<UserCartScreen> createState() => _UserCartScreenState();
}

class _UserCartScreenState extends State<UserCartScreen> {
  late Set<String> _cartSelectedIds;
  bool _isOrdering = false;
  bool _isLoading = true;
  var _cartItems = [];

  @override
  void initState() {
    super.initState();
    _cartSelectedIds = Set<String>.from(widget.selectedItemIds ?? []);
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      const String userId = 'current_user_id';
      var itemIds = widget.selectedItemIds ?? [];

      if (itemIds.isEmpty) {
        var cartDoc = await FirebaseFirestore.instance.collection('carts').doc(userId).get();
        if (cartDoc.exists && cartDoc.data() != null) {
          var data = cartDoc.data() as Map<String, dynamic>;
          itemIds = List<String>.from(data['itemIds'] ?? []);
        }
      }

      if (_cartSelectedIds.isEmpty) {
        _cartSelectedIds.addAll(itemIds);
      }

      var loadedItems = [];

      if (itemIds.isNotEmpty) {
        var tshirtSnapshot = await FirebaseFirestore.instance
            .collection('tshirts')
            .where(FieldPath.documentId, whereIn: itemIds)
            .get();

        for (var doc in tshirtSnapshot.docs) {
          loadedItems.add({
            'id': doc.id,
            ...(doc.data() as Map<String, dynamic>),
          });
        }

        var skinnySnapshot = await FirebaseFirestore.instance
            .collection('skinny_armcut')
            .where(FieldPath.documentId, whereIn: itemIds)
            .get();

        for (var doc in skinnySnapshot.docs) {
          loadedItems.add({
            'id': doc.id,
            ...(doc.data() as Map<String, dynamic>),
          });
        }

        var shortsSnapshot = await FirebaseFirestore.instance
            .collection('shorts_bottom')
            .where(FieldPath.documentId, whereIn: itemIds)
            .get();

        for (var doc in shortsSnapshot.docs) {
          loadedItems.add({
            'id': doc.id,
            ...(doc.data() as Map<String, dynamic>),
          });
        }
      }

      if (mounted) {
        setState(() {
          _cartItems = loadedItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeItemFromCart(String docId) async {
    try {
      const String userId = 'current_user_id';
      await FirebaseFirestore.instance.collection('carts').doc(userId).update({
        'itemIds': FieldValue.arrayRemove([docId]),
      });

      setState(() {
        _cartSelectedIds.remove(docId);
        _cartItems.removeWhere((item) => item['id'] == docId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart.')),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    double selectedTotalPrice = 0.0;
    int selectedCount = 0;

    for (var item in _cartItems) {
      if (_cartSelectedIds.contains(item['id'])) {
        selectedTotalPrice += (item['price'] ?? 0.0) as double;
        selectedCount++;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background5.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'CLOTHING SHOP',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cart',
                        style: TextStyle(color: Colors.white70, fontSize: 26, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _cartItems.isEmpty
                          ? const Center(
                              child: Text('Your cart is empty.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    itemCount: _cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _cartItems[index];
                                      final docId = item['id'];

                                      String name = item['name'] ?? 'No Name';
                                      String material = item['material'] ?? '';
                                      String attribute = item['sleeve'] ?? item['fit'] ?? item['type'] ?? '';
                                      dynamic price = item['price'] ?? 0.0;
                                      String imageBase64 = item['imageBase64'] ?? '';
                                      bool isChecked = _cartSelectedIds.contains(docId);

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          border: Border.all(
                                            color: isChecked ? Colors.amberAccent : Colors.white54,
                                            width: isChecked ? 1.5 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                width: 70,
                                                padding: const EdgeInsets.all(4),
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  border: Border(right: BorderSide(color: Colors.white54)),
                                                ),
                                                child: imageBase64.isNotEmpty
                                                    ? Image.memory(
                                                        base64Decode(imageBase64),
                                                        fit: BoxFit.cover,
                                                        height: 50,
                                                        width: 60,
                                                      )
                                                    : const Icon(Icons.image_not_supported, color: Colors.white54, size: 24),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Mat: $material | Info: $attribute',
                                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
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
                                                  style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Container(
                                                width: 45,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  border: Border(right: BorderSide(color: Colors.white54)),
                                                ),
                                                child: Checkbox( // Powerd by CP Fusion
                                                  value: isChecked,
                                                  activeColor: Colors.amberAccent,
                                                  checkColor: Colors.black,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        _cartSelectedIds.add(docId);
                                                      } else {
                                                        _cartSelectedIds.remove(docId);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _removeItemFromCart(docId),
                                                child: Container(
                                                  width: 45,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.85),
                                    border: const Border(top: BorderSide(color: Colors.white24)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Total Item : ',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '$selectedCount',
                                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text(
                                            'Total Price : ',
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Rs. ${selectedTotalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Center(
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
                                            onPressed: _cartSelectedIds.isEmpty
                                                ? null
                                                : () {
                                                    var checkedItems = _cartItems
                                                        .where((item) => _cartSelectedIds.contains(item['id']))
                                                        .toList();

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => UserCheckoutScreen(
                                                          selectedItemIds: _cartSelectedIds.toList(),
                                                          totalPrice: selectedTotalPrice,
                                                          cartItems: checkedItems,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: const Text(
                                              'Order',
                                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
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
}
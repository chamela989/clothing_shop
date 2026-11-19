import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCheckoutScreen extends StatefulWidget {
  final List<String> selectedItemIds;
  final double totalPrice;
  final List<dynamic> cartItems;

  const UserCheckoutScreen({
    Key? key,
    required this.selectedItemIds,
    required this.totalPrice,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<UserCheckoutScreen> createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Cash on Delivery (COD)';

  Future<void> _completeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      const String userId = 'current_user_id';

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'itemIds': widget.selectedItemIds,
        'totalPrice': widget.totalPrice,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'Confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('carts').doc(userId).set({
        'itemIds': FieldValue.arrayRemove(widget.selectedItemIds),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Payment Successful!', style: TextStyle(color: Colors.greenAccent)),
            content: Text(
              'Your order has been placed successfully using $_selectedPaymentMethod.\n\nTotal Paid: Rs. ${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout & Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Selected Items: ${widget.selectedItemIds.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Total Amount: Rs. ${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 30),
            const Text(
              'Select Free Payment Method',
              style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text('Cash on Delivery (COD)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Pay with cash when your clothes arrive', style: TextStyle(color: Colors.white54, fontSize: 12)),
              value: 'Cash on Delivery (COD)',
              groupValue: _selectedPaymentMethod,
              activeColor: Colors.amberAccent,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Bank Transfer (Mock Test)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Direct local bank deposit simulation', style: TextStyle(color: Colors.white54, fontSize: 12)),
              value: 'Bank Transfer',
              groupValue: _selectedPaymentMethod,
              activeColor: Colors.amberAccent,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _isProcessing ? null : _completeOrder,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        'Pay Rs. ${widget.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
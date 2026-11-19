import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfileManageUsersScreen extends StatefulWidget {
  const AdminProfileManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileManageUsersScreen> createState() => _AdminProfileManageUsersScreenState();
}

class _AdminProfileManageUsersScreenState extends State<AdminProfileManageUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image & Dark Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background7.png'),
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
                        'User Profile\nManage',
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

                // Real-time List of Registered Users from Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No registered users found.',
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
                          String email = data['email'] ?? 'No Email';
                          String phone = data['phone'] ?? 'No Phone';
                          bool isBlocked = data['isBlocked'] ?? false;
                          String imageBase64 = data['imageBase64'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isBlocked ? Colors.red.withOpacity(0.2) : Colors.black87,
                              border: Border.all(
                                color: isBlocked ? Colors.redAccent : Colors.white54,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 1. User Profile Image Column
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.white54)),
                                    ),
                                    child: imageBase64.isNotEmpty
                                        ? ClipOval(
                                            child: Image.memory(
                                              base64Decode(imageBase64),
                                              fit: BoxFit.cover,
                                              height: 55,
                                              width: 55,
                                            ),
                                          )
                                        : const Icon(Icons.account_circle, color: Colors.white54, size: 40),
                                  ),

                                  // 2. User Details Column
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              if (isBlocked)
                                                const Text(
                                                  '[BLOCKED]',
                                                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Email: $email',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Phone: $phone',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // 3. Clickable Edit/View Icon Column
                                  InkWell(
                                    onTap: () {
                                      _showUserProfileDialog(context, docId, data);
                                    },
                                    child: Container(
                                      width: 60,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        border: Border(left: BorderSide(color: Colors.white54)),
                                      ),
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

  // User Profile View & Block Dialog matching your wireframe
  void _showUserProfileDialog(BuildContext parentContext, String docId, Map<String, dynamic> data) {
    final scaffoldMessenger = ScaffoldMessenger.of(parentContext);

    String name = data['name'] ?? 'No Name';
    String email = data['email'] ?? 'No Email';
    String phone = data['phone'] ?? 'No Phone';
    bool isBlocked = data['isBlocked'] ?? false;
    String imageBase64 = data['imageBase64'] ?? '';

    bool isProcessing = false;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      'User Profile',
                      style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),

                    // User Profile Image Box (Non-editable view)
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration( // Powerd by CP Fusion 
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[900],
                        image: imageBase64.isNotEmpty
                            ? DecorationImage(image: MemoryImage(base64Decode(imageBase64)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: imageBase64.isEmpty
                          ? const Icon(Icons.account_circle, color: Colors.white70, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 25),

                    // Read-only Details Rows matching wireframe
                    _buildDetailRow('Name', name),
                    const SizedBox(height: 10),
                    _buildDetailRow('Email', email),
                    const SizedBox(height: 10),
                    _buildDetailRow('Mobile Number', phone),
                    const SizedBox(height: 10),
                    _buildDetailRow('ID', docId),
                    const SizedBox(height: 35),

                    // Block Button
                    SizedBox(
                      width: 160,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBlocked ? Colors.grey : Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setDialogState(() {
                                  isProcessing = true;
                                });

                                try {
                                  // Toggle or set block status to true
                                  bool newBlockStatus = !isBlocked;
                                  await FirebaseFirestore.instance.collection('users').doc(docId).update({
                                    'isBlocked': newBlockStatus,
                                  });

                                  Navigator.pop(dialogContext);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(newBlockStatus
                                          ? 'User blocked! They will no longer be able to log in.'
                                          : 'User unblocked successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                } finally {
                                  setDialogState(() {
                                    isProcessing = false;
                                  });
                                }
                              },
                        child: isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isBlocked ? 'Unblock User' : 'Block',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
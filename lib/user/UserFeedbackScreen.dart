import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFeedbackScreen extends StatefulWidget {
  final String userId;

  const UserFeedbackScreen({Key? key, this.userId = 'current_user_id'}) : super(key: key);

  @override
  State<UserFeedbackScreen> createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends State<UserFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String _userName = 'Customer';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the registered user's name from Firestore 'users' collection
  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['name'] ?? 'Customer';
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // Submit feedback to Firestore along with user ID, name, and timestamp
  Future<void> _submitFeedback() async {
    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your feedback before submitting!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': widget.userId,
        'userName': _userName,
        'feedback': feedbackText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _feedbackController.clear();
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Thank You!', style: TextStyle(color: Colors.amberAccent)),
            content: const Text(
              'Your feedback has been submitted successfully.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image & Dark Overlay matching app style
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          // 2. Main Content Layout matching wireframe
          SafeArea(
            child: _isLoadingUser
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
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
                            Text( // Powerd by CP Fusion
                              'Feed Back',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Box matching wireframe layout
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 280,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  border: Border.all(color: Colors.white70, width: 1.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextField(
                                  controller: _feedbackController,
                                  maxLines: 9,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                  decoration: const InputDecoration(
                                    hintText: 'Type your feedback here...',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),

                              // Submit Button matching wireframe
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
                                  onPressed: _isSubmitting ? null : _submitFeedback,
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator(color: Colors.black)
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
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
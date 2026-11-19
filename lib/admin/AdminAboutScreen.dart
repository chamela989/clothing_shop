import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAboutScreen extends StatefulWidget {
  const AdminAboutScreen({Key? key}) : super(key: key);

  @override
  State<AdminAboutScreen> createState() => _AdminAboutScreenState();
}

class _AdminAboutScreenState extends State<AdminAboutScreen> {
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Social Links state
  String _facebookUrl = '';
  String _instagramUrl = '';
  String _websiteUrl = '';
  String _tiktokUrl = '';

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  // Load existing About & Contact details from Firestore
  Future<void> _loadAboutData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shop_info')
          .doc('about')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _aboutController.text = data['aboutText'] ?? '';
        _addressController.text = data['address'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';

        Map<String, dynamic> social = data['social'] ?? {};
        setState(() {
          _facebookUrl = social['facebook'] ?? '';
          _instagramUrl = social['instagram'] ?? '';
          _websiteUrl = social['website'] ?? '';
          _tiktokUrl = social['tiktok'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading about data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  // Save all About & Contact details to Firestore
  Future<void> _saveAboutData() async {
    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.collection('shop_info').doc('about').set({
        'aboutText': _aboutController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'social': {
          'facebook': _facebookUrl.trim(),
          'instagram': _instagramUrl.trim(),
          'website': _websiteUrl.trim(),
          'tiktok': _tiktokUrl.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('About & Contact details saved successfully!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Edit popup to update social platform link
  void _editSocialLinkDialog(String platformName, String currentUrl, Function(String) onSave) {
    TextEditingController urlController = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Set $platformName Link', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: urlController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'https://...',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                onSave(urlController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image & Dark Overlay
          Container(
            decoration: const BoxDecoration( // Powerd by CP Fusion 
              image: DecorationImage(
                image: AssetImage('assets/images/Background1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
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
                              const SizedBox(height: 10),
                              const Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Outer Card Box wrapping About and Contact sections
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  border: Border.all(color: Colors.white70, width: 1.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Top About Text Area
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        controller: _aboutController,
                                        maxLines: 6,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        decoration: const InputDecoration(
                                          hintText: 'Enter shop description and about details here...',
                                          hintStyle: TextStyle(color: Colors.white38),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),

                                    // Divider Line
                                    Container(
                                      height: 1.2,
                                      color: Colors.white70,
                                    ),

                                    // Contact Section
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Center(
                                            child: Text(
                                              'Contact',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),

                                          // Address Line
                                          _buildContactInputRow('Address', _addressController),
                                          const SizedBox(height: 12),

                                          // Email Line
                                          _buildContactInputRow('Email', _emailController, keyboardType: TextInputType.emailAddress),
                                          const SizedBox(height: 12),

                                          // Contact Number Line
                                          _buildContactInputRow('Contact Number', _phoneController, keyboardType: TextInputType.phone),
                                          const SizedBox(height: 20),

                                          // Social Media Links Row
                                          const Text(
                                            'Social :',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildSocialIconButton(
                                                icon: Icons.facebook,
                                                label: 'FB',
                                                url: _facebookUrl,
                                                color: Colors.blueAccent,
                                                onEdit: () => _editSocialLinkDialog('Facebook', _facebookUrl, (val) => setState(() => _facebookUrl = val)),
                                              ),
                                              _buildSocialIconButton(
                                                icon: Icons.camera_alt,
                                                label: 'Instagram',
                                                url: _instagramUrl,
                                                color: Colors.pinkAccent,
                                                onEdit: () => _editSocialLinkDialog('Instagram', _instagramUrl, (val) => setState(() => _instagramUrl = val)),
                                              ),
                                              _buildSocialIconButton(
                                                icon: Icons.language,
                                                label: 'Web',
                                                url: _websiteUrl,
                                                color: Colors.tealAccent,
                                                onEdit: () => _editSocialLinkDialog('Website', _websiteUrl, (val) => setState(() => _websiteUrl = val)),
                                              ),
                                              _buildSocialIconButton(
                                                icon: Icons.music_note,
                                                label: 'TikTok',
                                                url: _tiktokUrl,
                                                color: Colors.white,
                                                onEdit: () => _editSocialLinkDialog('TikTok', _tiktokUrl, (val) => setState(() => _tiktokUrl = val)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),

                              // Save Button
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _saveAboutData,
                                  child: _isLoading
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
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInputRow(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 130,
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
      ],
    );
  }

  Widget _buildSocialIconButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
    required VoidCallback onEdit,
  }) {
    bool hasUrl = url.isNotEmpty;

    return Column(
      children: [
        InkWell(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black45,
              border: Border.all(
                color: hasUrl ? color : Colors.white38,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: hasUrl ? color : Colors.white38,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onEdit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: hasUrl ? Colors.white : Colors.white54,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.edit, color: Colors.white38, size: 10),
            ],
          ),
        ),
      ],
    );
  }
}
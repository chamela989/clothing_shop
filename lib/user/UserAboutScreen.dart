import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAboutScreen extends StatelessWidget {
  const UserAboutScreen({Key? key}) : super(key: key);

  // Helper method to open links safely
  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

          // 2. Main Content via StreamBuilder for Real-time Admin Sync
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('shop_info')
                        .doc('about')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      var data = snapshot.hasData && snapshot.data!.exists
                          ? snapshot.data!.data() as Map<String, dynamic>
                          : {};

                      String aboutText = data['aboutText'] ?? 'Welcome to our clothing shop! Quality apparel designed for your style.';
                      String address = data['address'] ?? 'Not specified';
                      String email = data['email'] ?? 'Not specified';
                      String phone = data['phone'] ?? 'Not specified';

                      Map<String, dynamic> social = data['social'] ?? {};
                      String facebook = social['facebook'] ?? '';
                      String instagram = social['instagram'] ?? '';
                      String website = social['website'] ?? '';
                      String tiktok = social['tiktok'] ?? '';

                      return SingleChildScrollView(
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
                                    child: Text(
                                      aboutText,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                                    ),
                                  ),

                                  // Divider Line
                                  Container(
                                    height: 1.2,
                                    color: Colors.white70,
                                  ),

                                  // Contact Section at the Bottom
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
                                        _buildContactDisplayRow('Address', address),
                                        const SizedBox(height: 12),

                                        // Email Line
                                        _buildContactDisplayRow('Email', email),
                                        const SizedBox(height: 12),

                                        // Contact Number Line
                                        _buildContactDisplayRow('Contact Number', phone),
                                        const SizedBox(height: 20),

                                        // Social Media Links Row (Shows only if admin added them)
                                        if (facebook.isNotEmpty || instagram.isNotEmpty || website.isNotEmpty || tiktok.isNotEmpty) ...[
                                          const Text(
                                            'Social :',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (facebook.isNotEmpty)
                                                _buildSocialIcon(Icons.facebook, 'FB', Colors.blueAccent, () => _launchURL(facebook)),
                                              if (instagram.isNotEmpty)
                                                _buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.pinkAccent, () => _launchURL(instagram)),
                                              if (website.isNotEmpty)
                                                _buildSocialIcon(Icons.language, 'Web', Colors.tealAccent, () => _launchURL(website)),
                                              if (tiktok.isNotEmpty)
                                                _buildSocialIcon(Icons.music_note, 'TikTok', Colors.white, () => _launchURL(tiktok)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildContactDisplayRow(String label, String value) {
    return Row(//Powerd by CP Fusion
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black45,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
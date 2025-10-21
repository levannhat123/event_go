import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class ImprovedLocationCard extends StatelessWidget {
  final String title;
  final String line1;
  final String line2;

  const ImprovedLocationCard({
    super.key,
    required this.title,
    required this.line1,
    required this.line2,
  });

  Future<void> _launchMaps(BuildContext context) async {
    final String fullAddress = "$title, $line1, $line2";
    final String query = Uri.encodeComponent(fullAddress);
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể mở bản đồ cho: $fullAddress')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchMaps(context),
          borderRadius: BorderRadius.circular(12.0),
          splashColor: Colors.blue.withOpacity(0.2),
          highlightColor: Colors.blue.withOpacity(0.1),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2F6FF), Color(0xFFE6EEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -40,
                    child: Icon(Icons.map_rounded, size: 150, color: Colors.white.withOpacity(0.7)),
                  ),
                  // Nội dung chính
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF1C2D56),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                line1,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              Text(
                                line2,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Icon Pin
                      Container(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.location_on, color: Colors.blue[500], size: 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

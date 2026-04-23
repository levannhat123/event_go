import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';

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
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.mapOpenError.replaceFirst('{address}', fullAddress),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.genericErrorWithDetails.replaceFirst('{error}', '$e'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.size10),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => _launchMaps(context),
          borderRadius: BorderRadius.circular(12.0),
          splashColor: Colors.blue.withOpacity(0.2),
          highlightColor: Colors.blue.withOpacity(0.1),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.colorFFF2F6FF, AppColors.colorFFE6EEFF],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: AppColors.white.withOpacity(0.5),
                width: AppSizes.size1_5,
              ),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -40,
                    child: Icon(
                      Icons.map_rounded,
                      size: AppSizes.size150,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.size10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.size18,
                                  color: AppColors.colorFF1C2D56,
                                ),
                              ),
                              const SizedBox(height: AppSizes.size8),
                              Text(
                                line1,
                                style: TextStyle(
                                  fontSize: AppSizes.size14,
                                  color: Colors.grey[600],
                                  height: AppSizes.size1_5,
                                ),
                              ),
                              Text(
                                line2,
                                style: TextStyle(
                                  fontSize: AppSizes.size14,
                                  color: Colors.grey[600],
                                  height: AppSizes.size1_5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.space24,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.space12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue[500],
                            size: AppSizes.size30,
                          ),
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

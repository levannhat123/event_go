import 'dart:io';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {


  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    const Color itemBackgroundColor = Color(0xFF2C2C2C);
    const Color secondaryTextColor = Color(0xFF8A8A8A);

    return BaseView<AuthViewModel>(
      viewModelBuilder: () => getIt<AuthViewModel>(),
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.initialize();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(viewModel),
                 SizedBox(height: AppSizes.size100),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: AppSpacing.space16
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsGroup(
                        icon: Icons.person_outline,
                        title: AppStrings.accountSettings,
                        backgroundColor: itemBackgroundColor,
                        children: [
                          _buildSettingsItem(
                            showDivider: false,
                            title: AppStrings.accountInfo,
                            onTap: ()async {
                              final didUpdate = await context.push<bool>(RouterPath.profile);
                              if (didUpdate == true && mounted) {
                                viewModel.refreshUserProfile();
                              }
                              // context.push(RouterPath.check_in);

                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildSettingsGroup(
                        icon: Icons.settings_outlined,
                        title: AppStrings.appSettings,
                        backgroundColor: itemBackgroundColor,
                        children: [_buildLanguageItem(onTap: () {})],
                      ),
                      const SizedBox(height: 40),
                      _buildSingleSettingsItem(
                        icon: Icons.logout,
                        title: AppStrings.logout,
                        backgroundColor: itemBackgroundColor,
                        onTap: () async {
                          // Gọi hàm signOut từ ViewModel
                          await viewModel.logout();
                          if (mounted) {
                            context.go(RouterPath.login);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  AppStrings.version,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Sửa lại để nhận ViewModel
  Widget _buildHeader(AuthViewModel viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 150,
          decoration: const BoxDecoration(color: Color(0xFF596DC3)),
        ),
        Positioned(
          bottom: -70,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 5),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF596DC3),
                  backgroundImage: () {
                    if (viewModel.imageFile != null) {
                      return FileImage(viewModel.imageFile!) as ImageProvider;
                    }
                    if (viewModel.networkAvatarUrl != null) {
                      return NetworkImage(viewModel.networkAvatarUrl!);
                    }
                    return null;
                  }(),
                  child:
                      (viewModel.imageFile == null &&
                          viewModel.networkAvatarUrl == null)
                      ? const Icon(
                          Icons.flutter_dash,
                          color: Colors.white,
                          size: 50,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.userEmail,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSingleSettingsItem({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16), // Thêm padding
        decoration: BoxDecoration(
          // Thêm decoration
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              color: Colors.grey.shade700,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.changeLanguage,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            AnimatedToggleSwitch<bool>.size(
              current: isDarkMode,
              values: const [false, true],
              iconOpacity: 0.3,
              indicatorSize: const Size(30, 30),
              borderWidth: 1.0,
              customIconBuilder: (context, local, global) => Text(
                local.value ? AppStrings.languageVietnamese : AppStrings.languageEnglish,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(
                    Colors.black,
                    Colors.white,
                    local.animationValue,
                  ),
                ),
              ),
              style: ToggleStyle(
                backgroundColor: Colors.white,
                borderColor: const Color(0xFF596DC3),
                indicatorColor: const Color(0xFF596DC3),
                borderRadius: BorderRadius.circular(20),
              ),
              onChanged: (b) {
                setState(() {
                  isDarkMode = b;
                });
              },
              iconAnimationType: AnimationType.onHover,
              height: 30,
              spacing: 1,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../view_models/locale_langue/locale_language_view_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    const Color itemBackgroundColor = AppColors.colorFF2C2C2C;
    const Color secondaryTextColor = AppColors.colorFF8A8A8A;

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
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsGroup(
                        icon: Icons.person_outline,
                        title: context.appLocaleLanguage.accountSettings,
                        backgroundColor: itemBackgroundColor,
                        children: [
                          _buildSettingsItem(
                            showDivider: false,
                            title: context.appLocaleLanguage.accountInfo,
                            onTap: () async {
                              final didUpdate = await context.push<bool>(
                                RouterPath.profile,
                              );
                              if (didUpdate == true && mounted) {
                                viewModel.refreshUserProfile();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.size40),
                      _buildSettingsGroup(
                        icon: Icons.settings_outlined,
                        title: context.appLocaleLanguage.appSettings,
                        backgroundColor: itemBackgroundColor,
                        children: [_buildLanguageItem(onTap: () {})],
                      ),
                      const SizedBox(height: AppSizes.size40),
                      _buildSingleSettingsItem(
                        icon: Icons.logout,
                        title: context.appLocaleLanguage.logout,
                        backgroundColor: itemBackgroundColor,
                        onTap: () async {
                          await viewModel.logout();
                          if (mounted) {
                            context.go(RouterPath.login);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.size40),
                Text(
                  context.appLocaleLanguage.version,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: AppSizes.size12,
                  ),
                ),
                const SizedBox(height: AppSizes.size20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuthViewModel viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: AppSizes.size150,
          decoration: const BoxDecoration(color: AppColors.homePrimaryBlue),
        ),
        Positioned(
          bottom: -70,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.colorFF1E1E1E,
                    width: AppSizes.size5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.homePrimaryBlue,
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
              const SizedBox(height: AppSizes.size8),
              Text(
                viewModel.userEmail,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.size18,
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
          padding: const EdgeInsets.only(
            left: AppSizes.size8,
            bottom: AppSizes.size8,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.size8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.size18),
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
        height: AppSizes.size50,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.size16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: AppSizes.size12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.size16,
                ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.size16,
              vertical: AppSizes.size14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.size16,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              color: Colors.grey.shade700,
              height: AppSizes.size1,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem({required VoidCallback onTap}) {
    return Consumer<LocaleNotifier>(
      builder: (context, localeNotifier, _) {
        bool isVietnamese = localeNotifier.locale.languageCode == 'vi';

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.size16,
              vertical: AppSizes.size14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.appLocaleLanguage.changeLanguage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.size16,
                    ),
                  ),
                ),
                AnimatedToggleSwitch<bool>.size(
                  current: isVietnamese,
                  values: const [false, true],
                  iconOpacity: 0.3,
                  indicatorSize: const Size(30, 30),
                  borderWidth: 1.0,
                  customIconBuilder: (context, local, global) => Text(
                    local.value ? "VI" : "EN",
                    style: TextStyle(
                      fontSize: AppSizes.size10,
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
                    borderColor: AppColors.homePrimaryBlue,
                    indicatorColor: AppColors.homePrimaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onChanged: (value) {
                    if (value) {
                      localeNotifier.setLocale(const Locale("vi"));
                    } else {
                      localeNotifier.setLocale(const Locale("en"));
                    }
                  },
                  iconAnimationType: AnimationType.onHover,
                  height: AppSizes.size30,
                  spacing: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

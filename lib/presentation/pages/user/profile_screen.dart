import 'dart:io';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/profile_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const Color _darkBackground = Color(0xFF1C1C1E);
  static const Color _fieldFillColor = Color(0xFF2C2C2E);
  static const Color _accentGreen = Color(0xFF34A853);
  static const Color _lightTextColor = Colors.white;
  static const Color _dimTextColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthViewModel>(
      autoDispose: false,
      viewModelBuilder: () => getIt<AuthViewModel>(),
      onModelReady: (viewModel) {
        viewModel.initialize();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF596DC3),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _lightTextColor),
              onPressed: () {
                context.pop();
              },
            ),
            title: Text(
              context.appLocaleLanguage.accountInfo,
              style: TextStyle(
                color: _lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: _darkBackground,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
            child: viewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFf49415)),
                  )
                : AppElevatedButton(
                    text: context.appLocaleLanguage.complete,
                    borderColor: Color(0xFFf49415),
                    color: Color(0xFFf49415),
                    splashColor: AppColors.transparent,
                    highlightColor: AppColors.white,
                    onPressed: () async {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) return;
                      final updatedProfile = ProfileModel(
                        id: user.id,
                        fullName: viewModel.nameController.text,
                        phone: viewModel.phoneController.text,
                        email: viewModel.emailController.text,
                      );
                      await viewModel.updateUserProfile(updatedProfile);
                      if (ScaffoldMessenger.of(context).mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.appLocaleLanguage.updateProfileSuccess),
                          ),
                        );
                      }
                      if (context.mounted) {
                        context.pop(true);
                      }
                    },
                  ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF596DC3),
                          backgroundImage: () {
                            if (viewModel.imageFile != null) {
                              return FileImage(viewModel.imageFile!)
                                  as ImageProvider;
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
                        Positioned(
                          bottom: 0,
                          right: -5,
                          child: InkWell(
                            onTap: () {
                              viewModel.pickImage();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF596DC3),
                                border: Border.all(
                                  color: _darkBackground,
                                  width: 2,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: _lightTextColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.appLocaleLanguage.profileInfoDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _dimTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel(context.appLocaleLanguage.fullName),
                  _buildTextField(controller: viewModel.nameController),
                  const SizedBox(height: 20),
                  _buildLabel(context.appLocaleLanguage.phoneNumber),
                  _buildPhoneField(viewModel.phoneController),
                  const SizedBox(height: 20),
                  _buildLabel(context.appLocaleLanguage.emailHint),
                  _buildTextField(
                    controller: viewModel.emailController,
                    readOnly: true,
                    suffixIcon: Icon(Icons.check, color: _accentGreen),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: _lightTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? _dimTextColor : _lightTextColor,
        fontSize: 16,
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _dimTextColor),
        filled: true,
        fillColor: readOnly ? Color(0xFF222224) : _fieldFillColor,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      keyboardType: TextInputType.phone,
    );
  }
}

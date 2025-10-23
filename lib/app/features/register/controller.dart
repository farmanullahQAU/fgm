import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class RegisterController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final Logger _logger = Logger();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim().isEmpty
        ? null
        : phoneController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      NotificationService.showError(
        'Error',
        'Please fill in all required fields',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      NotificationService.showError(
        'Error',
        'Please enter a valid email address',
      );
      return;
    }

    if (password.length < 8) {
      NotificationService.showError(
        'Error',
        'Password must be at least 8 characters',
      );
      return;
    }

    try {
      final success = await authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      if (success) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      NotificationService.showError('Registration Failed', e.toString());
    }
  }
}

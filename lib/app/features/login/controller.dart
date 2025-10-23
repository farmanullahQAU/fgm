import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final Logger _logger = Logger();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      NotificationService.showError('Error', 'Please fill in all fields');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      NotificationService.showError(
        'Error',
        'Please enter a valid email address',
      );
      return;
    }

    try {
      final success = await authService.login(email, password);
      if (success) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      _logger.e('Login error: $e');
      NotificationService.showError('Login Failed', e.toString());
    }
  }
}

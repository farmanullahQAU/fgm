import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Obx(() {
      // Show loading while checking auth
      if (authService.isLoading.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FlutterLogo(size: 100),
                // SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      }

      // Navigate based on auth state
      Future.delayed(Duration.zero, () {
        if (authService.isAuthenticated.value) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      });

      return Scaffold(body: Center(child: CircularProgressIndicator()));
    });
  }
}

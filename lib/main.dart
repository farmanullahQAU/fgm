import 'package:flutter/material.dart';
import 'package:fmac/app/bindings/login_binding.dart';
import 'package:fmac/app/features/login/login_screen.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/core/theme/app_theme.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart'; // You need to create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FmacApp());
}

void _initServices() {
  Get.put(AuthService());
}

class FmacApp extends StatelessWidget {
  const FmacApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For mobile, use full app routing
    return GetMaterialApp(
      title: 'FMAC',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      initialRoute: Routes.home,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      getPages: AppPages.pages,
      // navigatorKey: navigatorKey,
      initialBinding: InitialBinding(),
      home: const LoginScreen(),
    );
  }
}

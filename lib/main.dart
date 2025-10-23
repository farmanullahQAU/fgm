import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fmac/app/bindings/login_binding.dart';
import 'package:fmac/app/features/home/view.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/core/theme/app_theme.dart';
import 'package:fmac/core/values/app_constants.dart';
import 'package:fmac/services/api_services.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:fmac/services/stripe_services.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart'; // You need to create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const FmacApp());
}

Future<void> initServices() async {
  Stripe.publishableKey = stripePublicKey;
  await Stripe.instance.applySettings();
  Get.put(StripeService());

  // Initialize API Service first
  Get.put(ApiService(), permanent: true);

  // Initialize Auth Service
  Get.put(AuthService(), permanent: true);

  print('All services started...');
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
      initialRoute: AppRoutes.splash,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      getPages: AppPages.pages,
      // navigatorKey: navigatorKey,
      initialBinding: InitialBinding(),
      home: const HomeScreen(),
    );
  }
}

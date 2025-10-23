import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}

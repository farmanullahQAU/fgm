import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes
    ever(authService.isAuthenticated, (bool isAuth) {
      if (!isAuth) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      _logger.e('Logout error: $e');
    }
  }

  String get userDisplayName {
    final user = authService.user;
    if (user == null) return 'User';
    return '${user.firstName} ${user.lastName}'.trim();
  }

  String get userEmail => authService.user?.email ?? '';

  String get userPhone => authService.user?.phone ?? '';

  bool get isLoading => authService.isLoading.value;
}

import 'package:fmac/models/user.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final ApiService _apiService = Get.put(ApiService());

  final RxBool isAuthenticated = false.obs;
  final Rxn<User> currentUser = Rxn<User>();
  final RxnString accessToken = RxnString();
  final RxnString refreshToken = RxnString();

  // ---------------- LOGIN ----------------
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response.status.hasError) {
        throw Exception(response.body?['message'] ?? response.statusText);
      }

      final data = response.body['data'] as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final token = data['accessToken'] as String;
      final refresh = data['refreshToken'] as String?;

      accessToken.value = token;
      refreshToken.value = refresh;
      _apiService.setAuthToken(token);

      currentUser.value = user;
      isAuthenticated.value = true;

      return true;
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
      return false;
    }
  }

  // ---------------- REGISTER ----------------
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await _apiService.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (response.status.hasError) {
        throw Exception(response.body?['message'] ?? response.statusText);
      }

      final data = response.body['data'] as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final token = data['accessToken'] as String;
      final refresh = data['refreshToken'] as String?;

      accessToken.value = token;
      refreshToken.value = refresh;
      _apiService.setAuthToken(token);

      currentUser.value = user;
      isAuthenticated.value = true;

      return true;
    } catch (e) {
      print("Error: $e");
      Get.snackbar('Registration Failed', e.toString());
      return false;
    }
  }

  // ---------------- REFRESH TOKEN ----------------
  Future<bool> refreshAccessToken() async {
    if (refreshToken.value == null) return false;

    try {
      final response = await _apiService.refreshToken(refreshToken.value!);

      if (response.status.hasError) {
        throw Exception(response.body?['message'] ?? response.statusText);
      }

      final data = response.body['data'] as Map<String, dynamic>;
      accessToken.value = data['accessToken'] as String;
      refreshToken.value = data['refreshToken'] as String?;
      _apiService.setAuthToken(accessToken.value!);

      return true;
    } catch (e) {
      Get.snackbar('Session Expired', e.toString());
      await logout();
      return false;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      await _apiService.logout(refreshToken.value);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _clearSession();
      Get.offAllNamed('/login');
    }
  }

  // ---------------- LOGOUT ALL ----------------
  Future<void> logoutAll() async {
    try {
      await _apiService.logoutAll();
    } catch (e) {
      print('Logout-all error: $e');
    } finally {
      _clearSession();
      Get.offAllNamed('/login');
    }
  }

  // ---------------- HELPERS ----------------
  void _clearSession() {
    _apiService.clearAuthToken();
    accessToken.value = null;
    refreshToken.value = null;
    currentUser.value = null;
    isAuthenticated.value = false;
  }
}

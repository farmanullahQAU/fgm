import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/models/user.dart';
import 'package:fmac/services/api_services.dart';
import 'package:fmac/services/storage_services/token_storage_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

class AuthService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final TokenStorageService _tokenStorage = TokenStorageService();
  final Logger _logger = Logger();

  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    isLoading.value = true;
    try {
      if (await _tokenStorage.hasValidToken()) {
        final userData = await _tokenStorage.getUserData();
        if (userData != null) {
          currentUser.value = User.fromJson(jsonDecode(userData));
          isAuthenticated.value = true;
          currentUser.value = await _apiService
              .getUserProfile(); // Verify token
        }
      }
    } catch (e) {
      _logger.e('Auth initialization error: $e');
      await _clearSession();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _saveAuthData(Map<String, dynamic> data) async {
    try {
      final user = User.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String?;

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _tokenStorage.saveUserData(jsonEncode(user.toJson()));
      currentUser.value = user;
      isAuthenticated.value = true;
      return true;
    } catch (e) {
      _logger.e('Error saving auth data: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final data = await _apiService.login(email, password);
      final success = await _saveAuthData(data);
      if (success) {
        NotificationService.showSuccess(
          'Success',
          'Welcome back, ${currentUser.value!.firstName}!',
        );
      }
      return success;
    } catch (e) {
      NotificationService.showError('Login Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    isLoading.value = true;
    try {
      final data = await _apiService.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      final success = await _saveAuthData(data);
      if (success) {
        NotificationService.showSuccess(
          'Success',
          'Account created successfully!',
        );
      }
      return success;
    } catch (e) {
      NotificationService.showError('Registration Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiService.logout(refreshToken);
      }
    } catch (e) {
      _logger.e('Logout error: $e');
    } finally {
      await _clearSession();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiService.logoutAll();
    } catch (e) {
      _logger.e('Logout-all error: $e');
    } finally {
      await _clearSession();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _clearSession() async {
    await _tokenStorage.clearAll();
    currentUser.value = null;
    isAuthenticated.value = false;
  }

  User? get user => currentUser.value;

  bool hasRole(String role) => currentUser.value?.role == role;
}

// import 'dart:convert';

// import 'package:fmac/models/user.dart';
// import 'package:fmac/services/api_services.dart';
// import 'package:fmac/services/storage_services/token_storage_service.dart';
// import 'package:get/get.dart';

// class AuthService extends GetxController {
//   final ApiService _apiService = Get.find<ApiService>();
//   final TokenStorageService _tokenStorage = TokenStorageService();

//   final RxBool isAuthenticated = false.obs;
//   final RxBool isLoading = false.obs;
//   final Rxn<User> currentUser = Rxn<User>();

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeAuth();
//   }

//   // Initialize - Check for existing session
//   Future<void> _initializeAuth() async {
//     isLoading.value = true;

//     try {
//       final hasToken = await _tokenStorage.hasValidToken();

//       if (hasToken) {
//         // Try to load user data
//         final userData = await _tokenStorage.getUserData();
//         if (userData != null) {
//           currentUser.value = User.fromJson(jsonDecode(userData));
//           isAuthenticated.value = true;

//           // Optionally verify token by fetching profile
//           await _verifyToken();
//         }
//       }
//     } catch (e) {
//       print('Auth initialization error: $e');
//       await _clearSession();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Verify token is still valid
//   Future<void> _verifyToken() async {
//     try {
//       final user = await _apiService.getUserProfile();
//       currentUser.value = user;
//     } catch (e) {
//       print('Token verification failed: $e');
//       await _clearSession();
//     }
//   }

//   // ---------------- LOGIN ----------------
//   Future<bool> login(String email, String password) async {
//     try {
//       isLoading.value = true;

//       final response = await _apiService.login(email, password);

//       if (response.status.hasError) {
//         throw Exception(response.body?['message'] ?? 'Login failed');
//       }

//       final data = response.body['data'];
//       final user = User.fromJson(data['user']);
//       final accessToken = data['accessToken'] as String;
//       final refreshToken = data['refreshToken'] as String?;

//       // Save tokens securely
//       await _tokenStorage.saveTokens(
//         accessToken: accessToken,
//         refreshToken: refreshToken,
//       );

//       // Save user data
//       await _tokenStorage.saveUserData(jsonEncode(user.toJson()));

//       currentUser.value = user;
//       isAuthenticated.value = true;

//       Get.snackbar(
//         'Success',
//         'Welcome back, ${user.firstName}!',
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return true;
//     } catch (e) {
//       Get.snackbar(
//         'Login Failed',
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ---------------- REGISTER ----------------
//   Future<bool> register({
//     required String email,
//     required String password,
//     required String firstName,
//     required String lastName,
//     String? phone,
//   }) async {
//     try {
//       isLoading.value = true;

//       final response = await _apiService.signup(
//         email: email,
//         password: password,
//         firstName: firstName,
//         lastName: lastName,
//         phone: phone,
//       );

//       if (response.status.hasError) {
//         throw Exception(response.body?['message'] ?? 'Registration failed');
//       }

//       final data = response.body['data'];
//       final user = User.fromJson(data['user']);
//       final accessToken = data['accessToken'] as String;
//       final refreshToken = data['refreshToken'] as String?;

//       // Save tokens securely
//       await _tokenStorage.saveTokens(
//         accessToken: accessToken,
//         refreshToken: refreshToken,
//       );

//       // Save user data
//       await _tokenStorage.saveUserData(jsonEncode(user.toJson()));

//       currentUser.value = user;
//       isAuthenticated.value = true;

//       Get.snackbar(
//         'Success',
//         'Account created successfully!',
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return true;
//     } catch (e) {
//       Get.snackbar(
//         'Registration Failed',
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ---------------- LOGOUT ----------------
//   Future<void> logout() async {
//     try {
//       final refreshToken = await _tokenStorage.getRefreshToken();
//       if (refreshToken != null) {
//         await _apiService.logout(refreshToken);
//       }
//     } catch (e) {
//       print('Logout API error: $e');
//     } finally {
//       await _clearSession();
//       Get.offAllNamed('/login');
//     }
//   }

//   // ---------------- LOGOUT ALL ----------------
//   Future<void> logoutAll() async {
//     try {
//       await _apiService.logoutAll();
//     } catch (e) {
//       print('Logout-all error: $e');
//     } finally {
//       await _clearSession();
//       Get.offAllNamed('/login');
//     }
//   }

//   // ---------------- HELPERS ----------------
//   Future<void> _clearSession() async {
//     await _tokenStorage.clearAll();
//     currentUser.value = null;
//     isAuthenticated.value = false;
//   }

//   // Get current user safely
//   User? get user => currentUser.value;

//   // Check if user has specific role
//   bool hasRole(String role) {
//     return currentUser.value?.role == role;
//   }
// }

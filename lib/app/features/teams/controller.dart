import 'package:flutter/material.dart';
import 'package:fmac/models/team.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class TeamsController extends GetxController {
  final RxList<Team> teams = <Team>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt selectedTeamIndex = (-1).obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      isLoading.value = true;
      final apiService = Get.find<ApiService>();
      final response = await apiService.getTeams(page: currentPage.value);
      teams.assignAll(response.data);

      // Check if there are more teams based on pagination info
      hasMore.value =
          response.pagination.currentPage < response.pagination.totalPages;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final apiService = Get.find<ApiService>();
      final response = await apiService.getTeams(page: currentPage.value);

      // Check if there are more pages based on pagination info
      hasMore.value =
          response.pagination.currentPage < response.pagination.totalPages;

      teams.addAll(response.data);
    } catch (e) {
      currentPage.value--; // Revert page increment on error
      Get.snackbar(
        'Error',
        'Failed to load more teams',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void selectTeam(int index) {
    selectedTeamIndex.value = index;
  }

  void clearSelection() {
    selectedTeamIndex.value = -1;
  }

  Future<void> refreshTeams() async {
    currentPage.value = 1;
    hasMore.value = true;
    selectedTeamIndex.value = -1;
    await _fetchTeams();
  }

  String getCountryFlag(Team team) {
    // Use flag emoji from country object if available
    final flagEmoji = team.getFlagEmoji();
    if (flagEmoji.isNotEmpty) {
      return flagEmoji;
    }
    // Return empty string if no flag data available
    return '';
  }

  String getCountryName(Team team) {
    // Use country name from country object if available
    final countryName = team.getCountryName();
    if (countryName.isNotEmpty) {
      return countryName;
    }
    // Return empty string if no country name available
    return '';
  }

  String getContinent(Team team) {
    // Get continent from country object if available
    final continent = team.getContinent();
    if (continent.isNotEmpty) {
      // Format continent: "ASIA" -> "Asia", "EUROPE" -> "Europe", etc.
      if (continent.length > 1) {
        return continent[0] + continent.substring(1).toLowerCase();
      }
      return continent;
    }
    return '';
  }
}

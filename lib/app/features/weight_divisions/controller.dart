import 'package:flutter/material.dart';
import 'package:fmac/models/weight_division_participant.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class WeightDivisionsController extends GetxController {
  final RxList<WeightDivisionParticipant> participants =
      <WeightDivisionParticipant>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedWeightCategory = ''.obs;

  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    _fetchWeightDivisions();
  }

  Future<void> _fetchWeightDivisions({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        currentPage = 1;
      }

      final apiService = Get.find<ApiService>();
      final response = await apiService.getWeightDivisions(
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : null,
        weightCategory: selectedWeightCategory.value.isNotEmpty
            ? selectedWeightCategory.value
            : null,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        page: currentPage,
        limit: 10,
      );

      if (loadMore) {
        participants.addAll(response.data);
      } else {
        participants.assignAll(response.data);
      }

      currentPage = response.pagination.currentPage;
      totalPages = response.pagination.totalPages;
      hasMore = currentPage < totalPages;
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
      isLoadingMore.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _debounceSearch();
  }

  void _debounceSearch() {
    // Debounce search implementation
    // For simplicity, we'll just search on change
    _fetchWeightDivisions();
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
    _fetchWeightDivisions();
  }

  void selectWeightCategory(String category) {
    selectedWeightCategory.value = category;
    _fetchWeightDivisions();
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore) {
      currentPage++;
      _fetchWeightDivisions(loadMore: true);
    }
  }

  void onSort(String column) {
    final List<WeightDivisionParticipant> sorted = List.from(participants);

    switch (column.toLowerCase()) {
      case 'id':
        sorted.sort((a, b) => a.participantId.compareTo(b.participantId));
        break;
      case 'wt':
        sorted.sort(
          (a, b) => a.attributes.country.compareTo(b.attributes.country),
        );
        break;
      case 'cat.':
        sorted.sort((a, b) => a.event.name?.compareTo(b.event.name ?? '') ?? 0);
        break;
      case 'event':
        sorted.sort((a, b) => a.event.name?.compareTo(b.event.name ?? '') ?? 0);
        break;
      case 'rank':
        sorted.sort((a, b) => a.rank.compareTo(b.rank));
        break;
    }

    participants.assignAll(sorted);
  }

  String getCountryFlag(String countryCode) {
    final countryFlags = {
      'UAE': '🇦🇪',
      'KSA': '🇸🇦',
      'MAR': '🇲🇦',
      'BRN': '🇧🇭',
      'JOR': '🇯🇴',
      'KUW': '🇰🇼',
      'CHA': '🇹🇩',
      'EGY': '🇪🇬',
      'IRQ': '🇮🇶',
      'LBN': '🇱🇧',
      'LBY': '🇱🇾',
      'OMN': '🇴🇲',
      'PSE': '🇵🇸',
      'QAT': '🇶🇦',
      'SYR': '🇸🇾',
      'TUN': '🇹🇳',
      'YEM': '🇾🇪',
      'ALG': '🇩🇿',
    };
    return countryFlags[countryCode] ?? '🏳️';
  }

  String getCountryName(String countryCode) {
    final countryNames = {
      'UAE': 'United Arab Emirates',
      'KSA': 'Saudi Arabia',
      'MAR': 'Morocco',
      'BRN': 'Bahrain',
      'JOR': 'Jordan',
      'KUW': 'Kuwait',
      'CHA': 'Chad',
      'EGY': 'Egypt',
      'IRQ': 'Iraq',
      'LBN': 'Lebanon',
      'LBY': 'Libya',
      'OMN': 'Oman',
      'PSE': 'Palestine',
      'QAT': 'Qatar',
      'SYR': 'Syria',
      'TUN': 'Tunisia',
      'YEM': 'Yemen',
      'ALG': 'Algeria',
    };
    return countryNames[countryCode] ?? countryCode;
  }

  String getMedalIcon(String medalType) {
    switch (medalType.toLowerCase()) {
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
        return '🥉';
      default:
        return '';
    }
  }
}

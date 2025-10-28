import 'package:flutter/material.dart';
import 'package:fmac/models/random_weigh_in.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class RandomWeighInController extends GetxController {
  final RxList<RandomWeighIn> events = <RandomWeighIn>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Track expanded state for each date
  final RxMap<DateTime, bool> expandedDates = <DateTime, bool>{}.obs;

  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = true;

  // Group events by date
  Map<DateTime, List<RandomWeighIn>> get groupedEvents {
    final Map<DateTime, List<RandomWeighIn>> grouped = {};
    for (final event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }
    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    fetchRandomWeighIns();
  }

  Future<void> fetchRandomWeighIns({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        currentPage = 1;
      }

      final apiService = Get.find<ApiService>();
      final response = await apiService.getRandomWeighIns(
        page: currentPage,
        limit: 10,
      );

      if (loadMore) {
        events.addAll(response.data);
      } else {
        events.assignAll(response.data);
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

  Future<void> loadMore() async {
    if (hasMore && !isLoadingMore.value) {
      currentPage++;
      await fetchRandomWeighIns(loadMore: true);
    }
  }

  @override
  void refresh() {
    currentPage = 1;
    fetchRandomWeighIns();
  }

  void downloadPdf(String? pdfUrl) {
    if (pdfUrl != null) {
      // TODO: Implement PDF download
      Get.snackbar('Info', 'Downloading PDF: $pdfUrl');
    }
  }

  void toggleExpanded(DateTime date) {
    expandedDates[date] = !(expandedDates[date] ?? true);
  }

  bool isExpanded(DateTime date) {
    return expandedDates[date] ?? true;
  }
}

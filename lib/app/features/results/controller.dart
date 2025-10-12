import 'package:flutter/material.dart';
import 'package:fmac/models/result.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsController extends GetxController {
  final RxList<Result> results = <Result>[].obs;
  final RxSet<int> expandedDateIndices = RxSet<int>();
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;

  bool _isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      isLoading.value = true;
      final apiService = Get.find<ApiService>();
      final response = await apiService.getResults(page: currentPage.value);
      results.assignAll(response.data);

      // Automatically expand the first date group
      if (results.isNotEmpty) {
        expandedDateIndices.add(0);
      }

      // Check if there are more results
      hasMore.value = response.data.isNotEmpty && response.data.length >= 10;
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
    if (_isLoadingMore || !hasMore.value || isLoading.value) return;

    try {
      _isLoadingMore = true;
      isLoading.value = true; // Show loading indicator
      currentPage.value++;

      final apiService = Get.find<ApiService>();
      final response = await apiService.getResults(page: currentPage.value);

      if (response.data.isEmpty || response.data.length < 10) {
        hasMore.value = false;
      }

      results.addAll(response.data);
    } catch (e) {
      currentPage.value--; // Revert page increment on error
      Get.snackbar(
        'Error',
        'Failed to load more results',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingMore = false;
      isLoading.value = false;
    }
  }

  void toggleDateExpansion(int index) {
    if (expandedDateIndices.contains(index)) {
      expandedDateIndices.remove(index);
    } else {
      expandedDateIndices.add(index);
    }
  }

  Future<void> downloadPdf(String pdfUrl) async {
    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $pdfUrl';
      }
    } catch (e) {
      Get.snackbar(
        'Download Error',
        'Failed to open PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshResults() async {
    currentPage.value = 1;
    hasMore.value = true;
    expandedDateIndices.clear();
    await _fetchResults();
  }
}

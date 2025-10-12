import 'package:fmac/models/schedule.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final schedules = <Schedule>[].obs;
  final expandedDateIndices = <int>{}.obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getSchedules(page: currentPage.value);
      schedules.assignAll(response.data);
      totalPages.value = response.pagination.totalPages;
      hasMore.value = currentPage.value < totalPages.value;
      expandedDateIndices.add(currentPage.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedules: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSchedules() async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;
      final nextPage = currentPage.value + 1;
      final response = await _apiService.getSchedules(page: nextPage);

      if (response.data.isNotEmpty) {
        schedules.addAll(response.data);
        currentPage.value = nextPage;
        totalPages.value = response.pagination.totalPages;
        hasMore.value = currentPage.value < totalPages.value;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load more schedules: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSchedules() async {
    try {
      currentPage.value = 1;
      expandedDateIndices.clear();
      await loadSchedules();
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh schedules: $e');
    }
  }

  void toggleDateExpansion(int index) {
    if (expandedDateIndices.contains(index)) {
      expandedDateIndices.remove(index);
    } else {
      expandedDateIndices.add(index);
    }
  }
}

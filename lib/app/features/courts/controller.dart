import 'package:fmac/models/court.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class CourtsController extends GetxController {
  final ApiService _apiService = Get.find();

  final RxList<Court> courts = <Court>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourts();
  }

  Future<void> fetchCourts() async {
    try {
      isLoading.value = true;
      final results = await _apiService.getCourts();
      courts.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load courts: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() {
    fetchCourts();
  }
}


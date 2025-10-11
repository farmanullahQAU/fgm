import 'package:fmac/models/sponsor.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class SponsorController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final sponsors = <Sponsor>[].obs;
  final pagination = Rxn<Pagination>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    fetchSponsors();
    super.onInit();
  }

  Future<void> fetchSponsors({int page = 1}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiService.getSponsors(page: page);
      sponsors.assignAll(response.data);
      pagination.value = response.pagination;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveSponsors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiService.getActiveSponsors();
      sponsors.assignAll(response.data);
      pagination.value = response.pagination;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSponsorsByCategory(String category) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiService.getSponsorsByCategory(category);
      sponsors.assignAll(response.data);
      pagination.value = response.pagination;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSponsor(Sponsor sponsor) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final newSponsor = await _apiService.createSponsor(sponsor);
      sponsors.add(newSponsor);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:fmac/models/moved_match.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class MovedMatchesController extends GetxController {
  final ApiService _apiService = Get.find();

  final RxList<MovedMatch> matches = <MovedMatch>[].obs;
  final RxBool isLoading = false.obs;
  final searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMovedMatches();
  }

  Future<void> fetchMovedMatches({String? search}) async {
    try {
      isLoading.value = true;
      final results = await _apiService.getMovedMatches(search: search);
      matches.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load moved matches: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    fetchMovedMatches(search: value.isNotEmpty ? value : null);
  }

  void refresh() {
    searchText.value = '';
    fetchMovedMatches();
  }
}


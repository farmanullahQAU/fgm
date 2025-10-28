import 'package:fmac/models/court_details.dart';
import 'package:fmac/models/match.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class CourtDetailsController extends GetxController {
  final ApiService _apiService = Get.find();

  final Rxn<CourtDetails> courtDetails = Rxn<CourtDetails>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int mat = 0;

  @override
  void onInit() {
    super.onInit();
    mat = Get.arguments ?? 1;
    fetchCourtDetails();
  }

  Future<void> fetchCourtDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final details = await _apiService.getCourtDetails(mat);
      courtDetails.value = details;
    } catch (e) {
      errorMessage.value = 'Failed to load court details: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() {
    fetchCourtDetails();
  }

  List<Match> get upcomingMatches => courtDetails.value?.upcomingMatches ?? [];
  List<Match> get liveMatches => courtDetails.value?.liveMatches ?? [];
}

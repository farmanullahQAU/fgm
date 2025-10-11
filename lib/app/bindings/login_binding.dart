import 'package:fmac/services/api_services.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.put(AuthService());
      Get.put(ApiService());

      // Get.lazyPut(() => TopicsController());
    } catch (e) {}
  }
}

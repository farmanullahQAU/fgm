import 'package:fmac/app/features/home/controller.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class InitialBisndings extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => HomeController());
      Get.lazyPut(() => ApiService());

      // Get.lazyPut(() => CanvasController());
      // Get.lazyPut(() => ProfileController());
      // Get.lazyPut(() => AuthController());
      // Get.lazyPut(() => ShapeEditorController());
      // Get.lazyPut<IconPickerController>(() => IconPickerController());

      // Get.lazyPut(() => CategoryTemplatesController());

      // Get.lazyPut(() => InitializationService(), fenix: true);

      // // Get.lazyPut(() => TrendingController());
      // Get.lazyPut(() => PermissionService());
      // Get.lazyPut(() => AuthService(), fenix: true);
      // Get.lazyPut(() => FirestoreServices(), fenix: true);
      // Get.lazyPut(() => FirebaseStorageService(), fenix: true);
    } catch (e) {}
  }
}

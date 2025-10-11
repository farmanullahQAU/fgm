import 'package:fmac/app/features/home/view.dart';
import 'package:fmac/app/features/login/login_screen.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.home, page: () => HomeScreen()),

    GetPage(name: Routes.auth, page: () => const LoginScreen()),
    // GetPage(
    //   name: Routes.editor,
    //   page: () => EditorPage(),
    //   binding: InitialBindings(),
    // ),
  ];
}

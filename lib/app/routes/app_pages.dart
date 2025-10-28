import 'package:fmac/app/features/court_details/view.dart';
import 'package:fmac/app/features/courts/view.dart';
import 'package:fmac/app/features/draw_list/view.dart';
import 'package:fmac/app/features/home/view.dart';
import 'package:fmac/app/features/login/login_screen.dart';
import 'package:fmac/app/features/moved_matches/view.dart';
import 'package:fmac/app/features/my_tickets/view.dart';
import 'package:fmac/app/features/random_weigh_in/view.dart';
import 'package:fmac/app/features/register/view.dart';
import 'package:fmac/app/features/splash.dart';
import 'package:fmac/app/features/team_details/view.dart';
import 'package:fmac/app/features/teams/view.dart';
import 'package:fmac/app/features/weight_divisions/view.dart';
import 'package:fmac/app/middle_wares/auth_middleware.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.teams,
      page: () => TeamsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.teamDetails,
      page: () => TeamDetailsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.weightDivisions,
      page: () => WeightDivisionsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.randomWeighIn,
      page: () => RandomWeighInView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.drawList,
      page: () => DrawListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.courts,
      page: () => CourtsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.courtDetails,
      page: () => CourtDetailsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.movedMatches,
      page: () => MovedMatchesView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.myTickets,
      page: () => MyTicketsView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

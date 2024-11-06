import 'package:fluffypawuser/controllers/authentication/authentication_controller.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/splash_screen/components/logo_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashLayout extends ConsumerStatefulWidget {
  const SplashLayout({super.key});

  @override
  ConsumerState<SplashLayout> createState() => _SplashLayoutState();
}
class _SplashLayoutState extends ConsumerState<SplashLayout> {
  @override
  void initState() {
    //ref.read(authController.notifier).getSettingsInfo();
    Future.delayed(const Duration(seconds: 3), () async {
      ref.read(hiveStoreService).getAuthToken().then((token) async {
        if (token == null) {
          context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        } else {
          ref.read(apiClientProvider).updateToken(token: token);
          await ref.read(profileController.notifier).getAccountDetails();
          //ref.read(dashboardController.notifier).getDashboardInfo();
          // ref.read(orderController.notifier).get(
          //       status: "Pending",
          //       page: 1,
          //       perPage: 10,
          //       pagination: false,
          //     );
          context.nav.pushNamedAndRemoveUntil(Routes.core, (route) => false);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // bottomNavigationBar: BottomCurveAnimation(),
      body: Center(
        child: LogoAnimation(),
      ),
    );
  }
}
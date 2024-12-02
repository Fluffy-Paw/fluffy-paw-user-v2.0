import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/authentication/authentication_controller.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/splash_screen/components/logo_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashLayout extends ConsumerStatefulWidget {
  const SplashLayout({super.key});

  @override
  ConsumerState<SplashLayout> createState() => _SplashLayoutState();
}

class _SplashLayoutState extends ConsumerState<SplashLayout> {
  Future<void> initializeApp() async {
    try {
      // Ensure Hive boxes are open
      if (!Hive.isBoxOpen(AppConstants.appSettingsBox)) {
        await Hive.openBox(AppConstants.appSettingsBox);
      }
      if (!Hive.isBoxOpen(AppConstants.userBox)) {
        await Hive.openBox(AppConstants.userBox);
      }

      // Get token from storage
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        if (mounted) {
          context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
        return;
      }

      // Validate token expiration using JWT decoder
      if (JwtDecoder.isExpired(token)) {
        // Token expired
        await ref.read(hiveStoreService).removeAllData(); // Clear stored data
        if (mounted) {
          context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
        return;
      }

      // Token valid, check role from token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? role = decodedToken[
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];

      if (role != "PetOwner") {
        // Invalid role
        await ref.read(hiveStoreService).removeAllData();
        if (mounted) {
          context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
        return;
      }

      // Valid token and correct role
      ref.read(apiClientProvider).updateToken(token: token);

      // Test token validity with a real API call
      try {
        await Future.wait([
          ref.read(profileController.notifier).getAccountDetails(),
          ref.read(petController.notifier).getPetList(),
        ]);

        if (mounted) {
          context.nav.pushNamedAndRemoveUntil(Routes.core, (route) => false);
        }
      } catch (e) {
        debugPrint('API Error: $e');
        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          // Token rejected by server
          await ref.read(hiveStoreService).removeAllData();
          if (mounted) {
            context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
          }
          return;
        }
        // Handle other API errors if needed
        rethrow;
      }
    } catch (e) {
      debugPrint('Initialization Error: $e');
      // For any other errors, redirect to login as a safe default
      if (mounted) {
        context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LogoAnimation(),
      ),
    );
  }
}

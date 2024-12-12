import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/models/register/register_model.dart';
import 'package:fluffypawuser/services/auth_service_provider.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationController extends StateNotifier<bool> {
  late final Ref ref;

  AuthenticationController(this.ref) : super(false);

  //late Settings _settings;

  // Future<bool> getSettingsInfo() async {
  //   try {
  //     final response = await ref.read(authServiceProvider).settings();
  //     _settings = Settings.fromMap(response.data['data']);
  //     return true;
  //   } catch (e) {å
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }
  // login
  Future<bool> login(
      {required String contact, required String password}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .login(contact: contact, password: password);
      //final userInfo = User.fromMap(response.data['data']);

      if (response.statusCode != 200) {
        state = false;
        return false;
      }
      final accessToken = response.data['data'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

      // Kiểm tra role nếu là "PetOwner" thì trả về false
      String? role = decodedToken[
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
      if (role == "Staff") {
        state = false;
        return false; // Nếu role là "PetOwner", trả về false
      }

      //ref.read(hiveStoreService).saveUserInfo(userInfo: userInfo);
      ref.read(hiveStoreService).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      await ref.read(profileController.notifier).getAccountDetails();
      //await ref.read(petController.notifier).getPetList();
      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }
  Future<bool> register(RegisterModel registerModel) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).register(registerModel);

      if (response.statusCode != 200) {
        state = false;
        return false;
      }
      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }

  Future<bool> forgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).forgotPassword(
            phoneNumber: phoneNumber,
            newPassword: newPassword,
          );

      if (response.statusCode != 200) {
        state = false;
        return false;
      }
      
      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      throw Exception('Có lỗi xảy ra khi đổi mật khẩu: ${e.toString()}');
    }
  }
}

final authController = StateNotifierProvider<AuthenticationController, bool>(
    (ref) => AuthenticationController(ref));

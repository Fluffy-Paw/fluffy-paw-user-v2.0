import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:fluffypawuser/models/profile/update_user_model.dart';
import 'package:fluffypawuser/services/profile_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends StateNotifier<bool> {
  final Ref ref;
  ProfileController(this.ref) : super(false);


  // get acccount details
  Future<void> getAccountDetails() async {
    try {
      final response =
          await ref.read(profileServiceProvider).getAccountDetails();
      final userInfo = UserModel.fromMap(response.data['data']);
      ref.read(hiveStoreService).saveUserInfo(userInfo: userInfo);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> updateUserProfile(UpdateUserModel updateData) async {
    try {
      state = true; // Start loading
      final response = await ref.read(profileServiceProvider).updateUserProfile(updateData);
      
      if (response.statusCode == 200) {
        // Update was successful, refresh user data
        await getAccountDetails();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      state = false; // End loading
    }
  }

}

final profileController = StateNotifierProvider<ProfileController, bool>(
    (ref) => ProfileController(ref));
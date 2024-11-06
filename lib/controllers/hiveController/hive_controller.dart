import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveController {
  final Ref ref;

  HiveController(this.ref);

  // save access token
  Future saveUserAuthToken({required String authToken}) async {
    final authBox = await Hive.openBox(AppConstants.appSettingsBox);
    await authBox.put(AppConstants.authToken, authToken); // Sửa key thành authToken
  }

  // remove access token
  Future removeUserAuthToken() async {
    final authBox = await Hive.openBox(AppConstants.appSettingsBox);
    authBox.delete(AppConstants.appSettingsBox);
  }

  // save user information
  Future saveUserInfo({required UserModel userInfo}) async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    userBox.put(AppConstants.userData, userInfo.toMap());
  }

  // save pet information
  Future<void> savePetInfo({required List<PetModel> pets}) async {
    final petBox = await Hive.openBox(AppConstants.petBox);

    // Chuyển List<PetModel> thành List<Map>
    final List<Map<String, dynamic>> petMaps =
        pets.map((pet) => pet.toMap()).toList();

    // Lưu vào Hive
    await petBox.put(AppConstants.petData, petMaps);
  }

// save pet behavior
  Future<void> savePetBehavior({required List<BehaviorCategory> pets}) async {
    final petBox = await Hive.openBox(AppConstants.petBehaviorBox);
    final List<Map<String, dynamic>> petMaps =
        pets.map((pet) => pet.toMap()).toList();

    // Lưu vào Hive
    await petBox.put(AppConstants.petBehaviorBox, petMaps);
  }

//Get Pet List
  List<PetModel> getPetInfo() {
    final petBox = Hive.box(AppConstants.petBox);
    final List<dynamic> petData =
        petBox.get(AppConstants.petData, defaultValue: []);

    return petData
        .map((data) => PetModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

//Get Pet Behavior
  List<BehaviorCategory> getPetBehavior() {
    final petBox = Hive.box(AppConstants.petBehaviorBox);
    final List<dynamic> petData =
        petBox.get(AppConstants.petBehaviorData, defaultValue: []);

    return petData
        .map(
            (data) => BehaviorCategory.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }


  //Remove Data When Sign Out
  Future<bool> removeAllData() async {
    try {
      await removeUserAuthToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  // get user auth token
  Future<String?> getAuthToken() async {
    final authBox = await Hive.openBox(AppConstants.appSettingsBox); // Sửa thành appSettingsBox
    return authBox.get(AppConstants.authToken); // Trực tiếp return giá trị
  }
}

final hiveStoreService = Provider((ref) => HiveController(ref));
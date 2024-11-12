import 'dart:io';

import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/common_response/common_response.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/pet/pet_request.dart';
import 'package:fluffypawuser/services/pet_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetController extends StateNotifier<bool> {
  final Ref ref;
  PetDetail? _petDetail;
  PetDetail? get petDetail => _petDetail;
  List<PetType>? _petTypes;
  List<PetModel>? _pets;
  List<PetModel>? get pets => _pets;
  List<PetType>? get petTypes => _petTypes;
  List<BehaviorCategory>? _behaviorCategories;
  List<BehaviorCategory>? get behaviorCategories => _behaviorCategories;
  PetController(this.ref) : super(false);
  Future<void> getPetList() async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).getPetList();
      _pets = PetModel.fromMapList(response.data['data']);
      //await ref.read(hiveStoreService).savePetInfo(pets: pets);

      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting pet list: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> getPetDetail(int id) async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).getPetDetail(id);
      _petDetail = PetDetail.fromMap(response.data['data']);
      state = false; // Changed from true to false
    } catch (e) {
      state = false;
      debugPrint(e.toString());
    }
  }

  Future<void> getPetBehavior() async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).getBehaviorCategory();
      List<BehaviorCategory> newBehaviorCategory =
          (response.data['data'] as List)
              .map((item) => BehaviorCategory.fromMap(item))
              .toList();

      // Cập nhật _behaviorCategories
      _behaviorCategories = newBehaviorCategory;

      final hiveService = ref.read(hiveStoreService);
      List<BehaviorCategory>? currentBehaviorCategory =
          await hiveService.getPetBehavior();
      if (currentBehaviorCategory == null ||
          currentBehaviorCategory != newBehaviorCategory) {
        await hiveService.savePetBehavior(pets: newBehaviorCategory);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      state = false;
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).deletePet(petId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<CommonResponse> addPet({
    required PetRequest petRequest,
    required File profile,
  }) async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).addPet(
            request: petRequest,
            profile: profile,
          );
      final message = response.data['message'];
      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return CommonResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<void> getPetType(int petTypeId) async {
    try {
      state = true;
      final response =
          await ref.read(petServiceProvider).getPetTypeList(petTypeId);
      _petTypes = (response.data['data'] as List)
          .map((item) => PetType.fromMap(item))
          .toList();
      state = false;
    } catch (e) {
      debugPrint('Error fetching pet types: $e');
      state = false;
    }
  }

  Future<CommonResponse> updatePet({
    required PetRequest petRequest,
    required File profile,
    required int id,
  }) async {
    try {
      state = true;
      final response = await ref.read(petServiceProvider).updatePet(
            request: petRequest,
            profile: profile,
            id: id,
          );
      final message = response.data['message'];
      if (response.statusCode == 200) {
        // Optionally refresh pet list or details after update
        await getPetDetail(id); // Refresh the specific pet's details
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (e) {
      debugPrint('Error updating pet: $e');
      state = false;
      return CommonResponse(isSuccess: false, message: e.toString());
    }
  }
}

final petController =
    StateNotifierProvider<PetController, bool>((ref) => PetController(ref));

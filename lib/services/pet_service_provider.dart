import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/pet/pet_request.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class PetProvider {
  Future<Response> getPetList();
  Future<Response> getPetDetail(int id);
  Future<Response> getBehaviorCategory();
  Future<Response> addPet({required PetRequest request, required File profile});
  Future<Response> getPetTypeList(int id);
  Future<Response> updatePet(
      {required PetRequest request, required File profile, required int id});
  Future<Response> deletePet(int petId);
}

class PetServiceProvider implements PetProvider {
  final Ref ref;

  PetServiceProvider(this.ref);
  @override
  Future<Response> getPetList() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getPetListUrl);
    return response;
  }

  @override
  Future<Response> getPetDetail(int id) async {
    final response = await ref
        .read(apiClientProvider)
        .get('${AppConstants.getPetDetailUrl}/$id');
    return response;
  }

  @override
  Future<Response> getBehaviorCategory() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getPetBehaviorUrl);
    return response;
  }

  @override
  Future<Response> addPet(
      {required PetRequest request, required File profile}) async {
    try {
      final authBox = await Hive.openBox(AppConstants.appSettingsBox);
      final String? token = authBox.get(AppConstants.authToken);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Tạo FormData với tên field viết hoa để match với API
      FormData formData = FormData.fromMap({
        'Name': request.name,
        'Decription': request.description,
        'Sex': request.sex,
        'Allergy': request.allergy,
        'BehaviorCategoryId': request.behaviorCategoryId,
        'IsNeuter': request.isNeuter,
        'PetTypeId': request.petTypeId,
        'Dob': request.dob,
        'Weight': request.weight,
        'MicrochipNumber': request.microchipNumber,
        'PetImage': await MultipartFile.fromFile(
          profile.path,
          filename: profile.path.split('/').last,
          contentType: DioMediaType.parse(
              'image/${profile.path.split('.').last}'), // Thêm content type
        ),
      });

      final response = await ref.read(apiClientProvider).post(
        AppConstants.addPet,
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in addPet: $e');
      rethrow;
    }
  }

  @override
  Future<Response> getPetTypeList(int id) async {
    final response =
        await ref.read(apiClientProvider).get('${AppConstants.getPetType}/$id');
    return response;
  }

  @override
  Future<Response> updatePet(
      {required PetRequest request,
      required File profile,
      required int id}) async {
    try {
      final authBox = await Hive.openBox(AppConstants.appSettingsBox);
      final String? token = authBox.get(AppConstants.authToken);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Tạo map data cơ bản
      final Map<String, dynamic> formMap = {
        'Name': request.name,
        'Decription': request.description,
        'Sex': request.sex,
        'Allergy': request.allergy,
        'BehaviorCategoryId': request.behaviorCategoryId,
        'IsNeuter': request.isNeuter,
        'PetTypeId': request.petTypeId,
        'Dob': request.dob,
        'Weight': request.weight,
        'MicrochipNumber': request.microchipNumber,
      };

      // Chỉ thêm PetImage nếu có ảnh mới
      if (profile.path.isNotEmpty) {
        String contentType;
        String extension = profile.path.split('.').last.toLowerCase();
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          case 'gif':
            contentType = 'image/gif';
            break;
          default:
            contentType = 'image/jpeg';
        }

        formMap['PetImage'] = await MultipartFile.fromFile(
          profile.path,
          filename: profile.path.split('/').last,
          contentType: DioMediaType.parse(contentType),
        );
      }

      FormData formData = FormData.fromMap(formMap);

      final response = await ref.read(apiClientProvider).patch(
        '${AppConstants.updatePet}/$id',
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in updatePet: $e');
      rethrow;
    }
  }
  
  @override
  Future<Response> deletePet(int petId) {
    final response = ref.read(apiClientProvider).delete('${AppConstants.deletePet}/$petId');
    return response;
  }
}

final petServiceProvider = Provider((ref) => PetServiceProvider(ref));

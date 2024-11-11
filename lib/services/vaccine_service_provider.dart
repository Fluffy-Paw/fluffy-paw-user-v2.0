import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_request.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class VaccineProvider {
  Future<Response> getVaccineByPetId(int petId);
  Future<Response> getVaccineDetail(int vaccineId);
  Future<Response> addVaccineForPet(
      {required VaccineRequest request, required File vaccineImage});
  Future<Response> updateVaccineForPet({
    required FormData formData,
    required int vaccineId,
  });
  Future<Response> deleteVaccine(int vaccineId);
}

class VaccineServiceProvider implements VaccineProvider {
  final Ref ref;

  VaccineServiceProvider(this.ref);
  @override
  Future<Response> getVaccineByPetId(int petId) {
    final response = ref
        .read(apiClientProvider)
        .get('${AppConstants.getVaccingByPetId}/$petId');
    return response;
  }

  @override
  Future<Response> getVaccineDetail(int vaccineId) {
    final response = ref
        .read(apiClientProvider)
        .get('${AppConstants.getVaccineDetail}/$vaccineId');
    return response;
  }

  @override
  Future<Response> addVaccineForPet(
      {required VaccineRequest request, required File vaccineImage}) async {
    try {
      // Mở box Hive để lấy token
      final authBox = await Hive.openBox(AppConstants.appSettingsBox);
      final String? token = authBox.get(AppConstants.authToken);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Tạo FormData từ VaccineRequest với tên field viết hoa để khớp với API
      FormData formData = FormData.fromMap({
        'PetId': request.petId.toString(),
        'Name': request.name,
        'VaccineImage': await MultipartFile.fromFile(
          vaccineImage.path,
          filename: vaccineImage.path.split('/').last,
          contentType: DioMediaType('image',
              vaccineImage.path.split('.').last), // Đảm bảo đúng loại nội dung
        ),
        'PetCurrentWeight': request.petCurrentWeight.toString(),
        'VaccineDate': request.vaccineDate,
        'NextVaccineDate': request.nextVaccineDate,
        'Description': request.description,
      });

      final response = await ref.read(apiClientProvider).post(
        AppConstants.addVaccine,
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in addVaccineForPet: $e');
      rethrow;
    }
  }
  @override
  Future<Response> updateVaccineForPet({
    required FormData formData,
    required int vaccineId,
  }) async {
    try {
      // Get token from Hive
      final authBox = await Hive.openBox(AppConstants.appSettingsBox);
      final String? token = authBox.get(AppConstants.authToken);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ref.read(apiClientProvider).patch(
        '${AppConstants.updateVaccine}/$vaccineId',
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in updateVaccineForPet service: $e');
      rethrow;
    }
  }
  
  @override
  Future<Response> deleteVaccine(int vaccineId) {
    // TODO: implement deleteVaccine
    final response = ref.read(apiClientProvider).delete('${AppConstants.deleteVaccine}/$vaccineId');
    return response;
  }
}


final vaccineServiceProvider = Provider((ref) => VaccineServiceProvider(ref));
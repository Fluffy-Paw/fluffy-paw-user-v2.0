import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_detail_model.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_model.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_request.dart';
import 'package:fluffypawuser/services/vaccine_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VaccineController extends StateNotifier<bool>{
  final Ref ref;
  VaccineController(this.ref) : super(false);
  // Vaccine list and details
  List<VaccineModel> _vaccineList = [];
  VaccineDetailModel? _vaccineDetail;

  List<VaccineModel>? get vaccineList => _vaccineList;
  VaccineDetailModel? get vaccineDetail => _vaccineDetail;

 Future<bool> getVaccineByPetId(int petId) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).getVaccineByPetId(petId);
      
      // Reset list trước khi cập nhật mới
      _vaccineList = [];
      
      if (response.statusCode == 404) {
        // Trường hợp không có dữ liệu - trả về true nhưng giữ list rỗng
        return true;
      }

      if (response.data['data'] != null) {
        _vaccineList = (response.data['data'] as List)
            .map((data) => VaccineModel.fromMap(Map<String, dynamic>.from(data)))
            .toList();
      }
      
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Xử lý trường hợp 404 - không có dữ liệu
        _vaccineList = [];
        return true;
      }
      debugPrint('DioError in getVaccineByPetId: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error in getVaccineByPetId: $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<bool> getVaccineDetail(int vaccineId) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).getVaccineDetail(vaccineId);
      _vaccineDetail = VaccineDetailModel.fromMap(response.data['data']);
      state = false;
      return true;
    } catch (e) {
      debugPrint('Error in getVaccineDetail: $e');
      state = false;
      rethrow;
    }
  }
  Future<bool> addVaccineForPet({required VaccineRequest request, required File vaccineImage}) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).addVaccineForPet(
        request: request,
        vaccineImage: vaccineImage,
      );

      if (response.statusCode == 200) {
        debugPrint('Vaccine added successfully for pet ID ${request.petId}');
      } else {
        debugPrint('Failed to add vaccine: ${response.statusMessage}');
      }

      state = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in addVaccineForPet: $e');
      state = false;
      rethrow;
    }
  }
  Future<bool> updateVaccineForPet({
    required FormData formData,
    required int vaccineId,
  }) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).updateVaccineForPet(
        formData: formData,
        vaccineId: vaccineId,
      );

      state = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in updateVaccineForPet: $e');
      state = false;
      rethrow;
    }
  }
  Future<bool> deleteVaccine(int vaccineId) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).deleteVaccine(vaccineId);
      
      // Xóa vaccine khỏi danh sách nếu có
      if (response.statusCode == 200 && _vaccineList != null) {
        _vaccineList = _vaccineList!.where((vaccine) => vaccine.id != vaccineId).toList();
      }
      
      state = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in deleteVaccine: $e');
      state = false;
      rethrow;
    }
  }
}

final vaccineController = StateNotifierProvider<VaccineController, bool>(
    (ref) => VaccineController(ref));
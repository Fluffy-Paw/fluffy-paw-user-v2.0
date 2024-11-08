import 'dart:io';

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
  List<VaccineModel>? _vaccineList;
  VaccineDetailModel? _vaccineDetail;

  List<VaccineModel>? get vaccineList => _vaccineList;
  VaccineDetailModel? get vaccineDetail => _vaccineDetail;

 Future<bool> getVaccineByPetId(int petId) async {
    try {
      state = true;
      final response = await ref.read(vaccineServiceProvider).getVaccineByPetId(petId);
      
      if (response.data['data'] != null) {
        _vaccineList = (response.data['data'] as List)
            .map((data) => VaccineModel.fromMap(Map<String, dynamic>.from(data)))
            .toList();
      } else {
        _vaccineList = [];
      }
      
      state = false;
      return true;
    } catch (e) {
      debugPrint('Error in getVaccineByPetId: $e');
      state = false;
      rethrow;
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
}

final vaccineController = StateNotifierProvider<VaccineController, bool>(
    (ref) => VaccineController(ref));
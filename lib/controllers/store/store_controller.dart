import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/pet/service_type_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/services/store_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreController extends StateNotifier<bool> {
  List<ServiceTypeModel>? _serviceTypeModel;
  List<ServiceTypeModel>? get petTypes => _serviceTypeModel;

  final Ref ref;
  StoreController(this.ref) : super(false);

  Future<void> getServiceTypeList() async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getServiceType();
      
      // Parse và lưu data
      _serviceTypeModel = ServiceTypeModel.fromMapList(response.data['data']);
      
      // Debug log
      debugPrint('Parsed Service Types: ${_serviceTypeModel?.map((e) => '${e.name}: ${e.id}')}');
      
      // Cập nhật state
      state = false;
      
      
    } catch (e) {
      state = false;
      debugPrint('Error getting store service: ${e.toString()}');
      rethrow;
    }
  }
}

final storeController = StateNotifierProvider<StoreController, bool>(
    (ref) => StoreController(ref));
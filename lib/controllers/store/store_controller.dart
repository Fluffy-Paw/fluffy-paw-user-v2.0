import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/pet/service_type_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/services/store_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreController extends StateNotifier<bool> {
  List<ServiceTypeModel>? _serviceTypeModel;
  List<ServiceTypeModel>? get petTypes => _serviceTypeModel;
  List<StoreModel>? _storeModel;
  List<StoreModel>? get storeModel => _storeModel;
  List<StoreModel>? _storesByService;
  List<StoreModel>? get storesByService => _storesByService;
  StoreModel? _selectedStore;
  StoreModel? get selectedStore => _selectedStore;
  List<StoreServiceModel>? _storeServices;
  List<StoreServiceModel>? get storeServices => _storeServices;
  List<ServiceTimeModel>? _serviceTime;
  List<ServiceTimeModel>? get serviceTime => _serviceTime;

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
  Future<void> getAllStore() async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getAllStore();
      
      // Parse và lưu data
      if (response.data['data'] != null) {
        final List<dynamic> storeList = response.data['data'];
        _storeModel = storeList
            .map((store) => StoreModel.fromMap(Map<String, dynamic>.from(store)))
            .toList();
        
        debugPrint('Loaded ${_storeModel?.length} stores');
      }
      
      state = false;
      
    } catch (e) {
      state = false;
      debugPrint('Error getting all stores: ${e.toString()}');
      rethrow;
    }
  }
  Future<void> getStoresByServiceType(int serviceTypeId) async {
    try {
      state = true;
      final response = await ref
          .read(storeServiceProvider)
          .getAllStoreByServiceTypeId(serviceTypeId);
      
      // Parse và lưu data
      if (response.data['data'] != null) {
        final List<dynamic> storeList = response.data['data'];
        _storesByService = storeList
            .map((store) => StoreModel.fromMap(Map<String, dynamic>.from(store)))
            .toList();
        
        debugPrint(
            'Loaded ${_storesByService?.length} stores for service type $serviceTypeId');
        
        // Log chi tiết các store tìm được
        _storesByService?.forEach((store) {
          debugPrint(
              'Store: ${store.name} (ID: ${store.id}) - Brand: ${store.brandName}');
        });
      }
      
      state = false;
      
    } catch (e) {
      state = false;
      debugPrint('Error getting stores by service type: ${e.toString()}');
      rethrow;
    }
  }
  Future<void> getStoreById(int storeId) async {
    if (!mounted) return;
    
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getStoreById(storeId);
      if (!mounted) return;

      if (response.data['data'] != null) {
        // Handle the case where data is an array
        final List<dynamic> storeList = response.data['data'];
        if (storeList.isNotEmpty) {
          // Take the first store from the array
          _selectedStore = StoreModel.fromMap(
            Map<String, dynamic>.from(storeList.first)
          );
          debugPrint('Loaded store: ${_selectedStore?.name} (ID: ${_selectedStore?.id})');
        }
      }
      if (mounted) state = false;
    } catch (e) {
      debugPrint('Error getting store by ID: $e');
      if (mounted) state = false;
      rethrow;
    }
  }

  Future<void> getStoreServiceByStoreId(int storeId) async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getStoreServiceByStoreId(storeId);
      if (response.data['data'] != null) {
        final List<dynamic> serviceList = response.data['data'];
        _storeServices = serviceList.map((service) => StoreServiceModel.fromMap(Map<String, dynamic>.from(service))).toList();
        debugPrint('Loaded ${_storeServices?.length} services for store ID $storeId');
        _storeServices?.forEach((service) {
          debugPrint('Service: ${service.name} (ID: ${service.id}) - Type: ${service.serviceTypeName}');
        });
      }
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting store services by store ID: ${e.toString()}');
      rethrow;
    }
  }
  Future<void> getServiceTime(int storeServiceId) async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getServiceTime(storeServiceId);
      if (response.data['data'] != null) {
        final List<dynamic> serviceList = response.data['data'];
        _serviceTime = serviceList.map((service) => ServiceTimeModel.fromMap(Map<String, dynamic>.from(service))).toList();
        debugPrint('Loaded ${_storeServices?.length} time services for store ID $storeServiceId');
        _storeServices?.forEach((service) {
          debugPrint('Service Time: ${service.name} (ID: ${service.id}) - Type: ${service.serviceTypeName}');
        });
      }
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting store services by store ID: ${e.toString()}');
      rethrow;
    }
  }
}

final storeController = StateNotifierProvider<StoreController, bool>(
    (ref) => StoreController(ref));
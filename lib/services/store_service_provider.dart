import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StoreProvider {
  Future<Response> getServiceType();
  Future<Response> getAllStore();
  Future<Response> getAllStoreByServiceTypeId(int serviceTypeId);
  Future<Response> getStoreServiceByStoreId(int storeId);
  Future<Response> getStoreById(int storeId);
  Future<Response> getServiceTime(int serviceStoreId);
  Future<Response> createBooking(int storeServiceId, List<int> petIds, String paymentMethod, String description);
  Future<Response> getAllBooking();
  Future<Response> selectBookingTime(int petId, List<int> storeServiceIds, String paymentMethod, String description);
  Future<Response> cancelBooking(int bookingId);
  Future<Response> getStoreServiceWithServiceType(int serviceTypeId);
  Future<Response> getStoresByServiceId(int serviceId);
  Future<Response> getBrandById(int brandId);
  Future<Response> getServiceTimeWithStoreId(int serviceStoreId, int storeId);
  Future<Response> getBookingById(int bookingId);
  Future<Response> getRecommendService();
  Future<Response> getTop6Services();


}

class StoreServiceProvider implements StoreProvider {
  final Ref ref;

  StoreServiceProvider(this.ref);
  @override
  Future<Response> getServiceType() async{
    
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getServiceType);
    return response;
  }
  
  @override
  Future<Response> getAllStore() async{
    final response = ref.read(apiClientProvider).get(AppConstants.getAllStore);
    return response;
  }
  
  @override
  Future<Response> getAllStoreByServiceTypeId(int serviceTypeId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getStoreByServiceTypeId}/$serviceTypeId');
    return response;
  }
  
  @override
  Future<Response> getStoreById(int storeId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getStoreById}/$storeId');
    return response;
  }
  @override
  Future<Response> getRecommendService() async {
    final response = await ref.read(apiClientProvider).get(AppConstants.recommendService);
    return response;
  }
  @override
  Future<Response> getTop6Services() async {
    try {
      final response = await ref.read(apiClientProvider).get(AppConstants.top6Services);
      return response;
    } catch (e) {
      debugPrint('Error getting top 6 services: $e');
      rethrow;
    }
  }
  
  @override
  Future<Response> getStoreServiceByStoreId(int storeId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getStoreServiceByStoreId}/$storeId');
    return response;
  }
  @override
  Future<Response> getStoreServiceWithServiceType(int serviceTypeId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getAllServiceByServiceTypeIdDateTime}?serviceTypeId=$serviceTypeId');
    return response;
  }
  
  @override
  Future<Response> getServiceTime(int serviceStoreId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getAllStoreServiceByServiceId}/$serviceStoreId');
    return response;
  }

  @override
  Future<Response> getServiceTimeWithStoreId(int serviceStoreId, int storeId) {
    final response = ref.read(apiClientProvider).get('${AppConstants.getAllStoreServiceByServiceIdStoreId}?serviceId=$serviceStoreId&storeId=$storeId');
    return response;
  }
  @override
  Future<Response> createBooking(int storeServiceId, List<int> petIds, String paymentMethod, String description) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.createBooking,
      data: {
        "petId": petIds,
        "storeServiceId": storeServiceId,
        "paymentMethod": paymentMethod,
        "description": description
      },
    );
    return response;
  }
  @override
  Future<Response> getAllBooking() {
    final response = ref
        .read(apiClientProvider)
        .get(AppConstants.getAllBooking);
    return response;
  }
  @override
  Future<Response> getBookingById(int bookingId) async {
    final response = await ref.read(apiClientProvider)
        .get('${AppConstants.getBookingById}/$bookingId');
    return response;
  }
  
  @override
  Future<Response> selectBookingTime(int petId, List<int> storeServiceIds, String paymentMethod, String description) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.createBookingTimeSelection,
      data: {
        "petId": petId,
        "storeServiceIds": storeServiceIds,
        "paymentMethod": paymentMethod,
        "description": description
      },
    );
    return response;
  }
  
  @override
  Future<Response> cancelBooking(int bookingId) {
   final response = ref
        .read(apiClientProvider)
        .patch('${AppConstants.cancelBooking}/$bookingId');
    return response;
  }
  @override
  Future<Response> getStoresByServiceId(int serviceId) async {
    final response = await ref
        .read(apiClientProvider)
        .get('${AppConstants.getAllStoreByServiceIdDateTime}?serviceId=$serviceId');
    return response;
  }
  @override
  Future<Response> getBrandById(int brandId) async {
    final response = await ref
        .read(apiClientProvider)
        .get('${AppConstants.brandById}/$brandId');
    return response;
  }

}

final storeServiceProvider = Provider((ref) => StoreServiceProvider(ref));
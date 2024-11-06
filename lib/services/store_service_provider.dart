import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StoreProvider {
  Future<Response> getServiceType();
  Future<Response> getAllStore();
  Future<Response> getAllStoreByServiceTypeId(int serviceTypeId);

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

}

final storeServiceProvider = Provider((ref) => StoreServiceProvider(ref));
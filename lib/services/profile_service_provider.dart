import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ProfileProvider{
  Future<Response> getAccountDetails();
}

class ProfileService implements ProfileProvider{
  final Ref ref;

  ProfileService(this.ref);
  @override
  Future<Response> getAccountDetails() async{
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getAccountDetails);
    return response;
  }

}

final profileServiceProvider = Provider((ref) => ProfileService(ref));
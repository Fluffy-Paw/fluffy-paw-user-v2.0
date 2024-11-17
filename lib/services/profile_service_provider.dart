import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/profile/update_user_model.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ProfileProvider{
  Future<Response> getAccountDetails();
  Future<Response> updateUserProfile(UpdateUserModel updateData);
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
  @override
  Future<Response> updateUserProfile(UpdateUserModel updateData) async {
    try {
      final formData = await updateData.toFormData();
      String? token = await ref.read(hiveStoreService).getAuthToken();
      
      if (token == null) {
        throw Exception('Unauthorized: No token found');
      }

      final response = await ref.read(apiClientProvider).patch(
        AppConstants.updateProfile,
        data: formData,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );

      if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception('Unauthorized: Please login again');
      }

      return response;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

}

final profileServiceProvider = Provider((ref) => ProfileService(ref));
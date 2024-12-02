import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class BookingRatingProvider {
  Future<Response> createRating(int bookingId, BookingRatingRequest request);
  Future<Response> updateRating(int ratingId, Map<String, dynamic> formData);
  Future<Response> getRating(int ratingId);
  Future<Response> getAllRatingsByServiceId(int serviceId);
  Future<Response> getAllRatingsByStoreId(int storeId);
}

class BookingRatingServiceProvider implements BookingRatingProvider {
  final Ref ref;

  BookingRatingServiceProvider(this.ref);

  @override
  Future<Response> createRating(
      int bookingId, BookingRatingRequest request) async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      FormData formData = FormData.fromMap({
        'ServiceVote': request.serviceVote,
        'StoreVote': request.storeVote,
        'Description': request.description,
        'Image': request.image != null
            ? await MultipartFile.fromFile(request.image!.path,
                filename: request.image!.name)
            : null,
      });

      final response = await ref.read(apiClientProvider).post(
        '${AppConstants.createRatingForBooking}/$bookingId',
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in createRating: $e');
      rethrow;
    }
  }


  @override
Future<Response> updateRating(int ratingId, Map<String, dynamic> formData) async {
  try {
    final token = await ref.read(hiveStoreService).getAuthToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    FormData form = FormData.fromMap(formData);

    final headers = {
      'accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };

    final response = await ref.read(apiClientProvider).patch(
          '${AppConstants.updateRatingForBooking}/$ratingId',
          data: form,
          headers: headers,
        );

    return response;
  } catch (e) {
    debugPrint('Error in updateRating: $e');
    rethrow;
  }
}

  @override
  Future<Response> getRating(int ratingId) async {
    final response = await ref
        .read(apiClientProvider)
        .get('${AppConstants.getRatingByRatingId}/$ratingId');
    return response;
  }

  @override
  Future<Response> getAllRatingsByServiceId(int serviceId) async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ref.read(apiClientProvider).get(
            '${AppConstants.getAllBookingRatingByServiceId}/$serviceId',
          );

      return response;
    } catch (e) {
      debugPrint('Error in getAllRatingsByServiceId: $e');
      rethrow;
    }
  }
  @override
  Future<Response> getAllRatingsByStoreId(int storeId) async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await ref.read(apiClientProvider).get(
        '${AppConstants.getAllBookingRatingByStoreId}/$storeId',
      );
      
      return response;
    } catch (e) {
      debugPrint('Error in getAllRatingsByStoreId: $e');
      rethrow;
    }
  }
}

final bookingRatingServiceProvider =
    Provider((ref) => BookingRatingServiceProvider(ref));

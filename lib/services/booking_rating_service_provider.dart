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
  Future<Response> updateRating(int ratingId, BookingRatingRequest request);
  Future<Response> getRating(int ratingId);
}

class BookingRatingServiceProvider implements BookingRatingProvider {
  final Ref ref;

  BookingRatingServiceProvider(this.ref);

  @override
  Future<Response> createRating(int bookingId, BookingRatingRequest request) async {
    try {
      //final authBox = await Hive.openBox(AppConstants.appSettingsBox);
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      FormData formData = FormData.fromMap({
        'Vote': request.vote,
        'Description': request.description,
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
  Future<Response> updateRating(int ratingId, BookingRatingRequest request) async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> data = {
        'Vote': request.vote,
        'Description': request.description,
      };

      final response = await ref.read(apiClientProvider).put(
        '${AppConstants.updateRatingForBooking}/$ratingId',
        data: data,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      debugPrint('Error in updateRating: $e');
      rethrow;
    }
  }

  @override
  Future<Response> getRating(int ratingId) async {
    final response = await ref.read(apiClientProvider)
        .get('${AppConstants.getRatingByRatingId}/$ratingId');
    return response;
  }
}

final bookingRatingServiceProvider = Provider((ref) => BookingRatingServiceProvider(ref));

import 'package:fluffypawuser/models/common_response/common_response.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/services/booking_rating_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingRatingController extends StateNotifier<bool> {
  final Ref ref;
  BookingRating? _bookingRating;
  BookingRating? get bookingRating => _bookingRating;

  BookingRatingController(this.ref) : super(false);

  Future<CommonResponse> createRating(int bookingId, BookingRatingRequest request) async {
    try {
      state = true;
      final response = await ref.read(bookingRatingServiceProvider).createRating(
        bookingId,
        request,
      );
      final message = response.data['message'];
      if (response.statusCode == 200) {
        _bookingRating = BookingRating.fromMap(response.data['data']);
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return CommonResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<CommonResponse> updateRating(int ratingId, BookingRatingRequest request) async {
    try {
      state = true;
      final response = await ref.read(bookingRatingServiceProvider).updateRating(
        ratingId,
        request,
      );
      final message = response.data['message'];
      if (response.statusCode == 200) {
        await getRating(ratingId); // Refresh rating data
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (e) {
      debugPrint('Error updating rating: $e');
      state = false;
      return CommonResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<void> getRating(int ratingId) async {
    try {
      state = true;
      final response = await ref.read(bookingRatingServiceProvider).getRating(ratingId);
      if (response.statusCode == 200) {
        _bookingRating = BookingRating.fromMap(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error getting rating: $e');
    } finally {
      state = false;
    }
  }
}

final bookingRatingController = StateNotifierProvider<BookingRatingController, bool>(
  (ref) => BookingRatingController(ref)
);
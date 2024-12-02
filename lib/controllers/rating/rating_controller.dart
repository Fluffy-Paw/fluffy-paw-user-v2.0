import 'package:dio/dio.dart';
import 'package:fluffypawuser/models/common_response/common_response.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/services/booking_rating_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingRatingController extends StateNotifier<bool> {
  final Ref ref;
  int? _selectedFilter;
  int? get selectedFilter => _selectedFilter;
  BookingRating? _bookingRating;
  BookingRating? get bookingRating => _bookingRating;

  List<BookingRating>? _ratings;

  List<BookingRating>? get ratings => _ratings;

  BookingRatingController(this.ref) : super(false);

  Future<void> createRating(int bookingId, BookingRatingRequest request) async {
    try {
      state = true;
      final response = await ref
          .read(bookingRatingServiceProvider)
          .createRating(bookingId, request);

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to create rating');
      }

      debugPrint('Rating created successfully for booking $bookingId');
    } catch (e) {
      debugPrint('Error creating rating: $e');
      throw e;
    } finally {
      state = false;
    }
  }

  Future<void> getStoreRatings(int storeId, {int? filterStar}) async {
    if (!mounted) return; // Kiểm tra mounted state

    try {
      // Sử dụng Future để delay state update
      Future(() {
        state = true;
      });

      _selectedFilter = filterStar;

      final response = await ref
          .read(bookingRatingServiceProvider)
          .getAllRatingsByStoreId(storeId);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        // Wrap state updates trong Future
        Future(() {
          _ratings = data.map((item) => BookingRating.fromMap(item)).toList();

          if (filterStar != null) {
            _ratings = _ratings
                ?.where((rating) => rating.storeVote == filterStar)
                .toList();
          }

          state = false;
        });
      } else {
        Future(() {
          state = false;
        });
        throw Exception(
            response.data['message'] ?? 'Failed to load store ratings');
      }
    } catch (e) {
      Future(() {
        state = false;
      });
      debugPrint('Error getting store ratings: $e');
      rethrow;
    }
  }

  // Phương thức lấy thống kê đánh giá của cửa hàng
  Map<int, dynamic> getStoreRatingStats() {
    if (_ratings == null || _ratings!.isEmpty) return {};

    final Map<int, dynamic> stats = {};
    final total = _ratings!.length.toDouble();

    for (int i = 1; i <= 5; i++) {
      final count = _ratings!.where((rating) => rating.storeVote == i).length;
      stats[i] = {
        'count': count,
        'percentage': (count / total * 100).toStringAsFixed(1),
      };
    }

    return stats;
  }

  // Lấy điểm đánh giá trung bình của cửa hàng
  double getAverageStoreRating() {
    if (_ratings == null || _ratings!.isEmpty) return 0;

    final sum = _ratings!.fold(0, (sum, rating) => sum + rating.storeVote);
    return double.parse((sum / _ratings!.length).toStringAsFixed(1));
  }

  // Lấy tổng số đánh giá của cửa hàng
  int getTotalStoreRatings() {
    return _ratings?.length ?? 0;
  }

  Future<CommonResponse> updateRating(
      int ratingId, Map<String, dynamic> formData) async {
    try {
      state = true;
      final response = await ref
          .read(bookingRatingServiceProvider)
          .updateRating(ratingId, formData);

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

  Future<void> getRating(int bookingId) async {
    try {
      state = true;
      final response =
          await ref.read(bookingRatingServiceProvider).getRating(bookingId);

      if (response.statusCode == 200) {
        _bookingRating = BookingRating.fromMap(response.data['data']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Xử lý yên lặng với lỗi 404
        _bookingRating = null;
        return; // Return ngay lập tức, không throw exception
      }
      debugPrint('Error getting rating: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error getting rating: $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> getServiceRatings(int serviceId,
      {int? filterStar, bool? isService}) async {
    try {
      state = true;
      _selectedFilter = filterStar;

      final response = await ref
          .read(bookingRatingServiceProvider)
          .getAllRatingsByServiceId(serviceId);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _ratings = data.map((item) => BookingRating.fromMap(item)).toList();

        if (filterStar != null) {
          if (isService != null) {
            // Filter by either service or store vote
            _ratings = _ratings
                ?.where((rating) => isService
                    ? rating.serviceVote == filterStar
                    : rating.storeVote == filterStar)
                .toList();
          } else {
            // If isService is not specified, include ratings that match either vote
            _ratings = _ratings
                ?.where((rating) =>
                    rating.serviceVote == filterStar ||
                    rating.storeVote == filterStar)
                .toList();
          }
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load ratings');
      }
    } catch (e) {
      debugPrint('Error getting ratings: $e');
      throw e;
    } finally {
      state = false;
    }
  }

  double getAverageRating({bool isService = true}) {
    if (_ratings == null || _ratings!.isEmpty) return 0;
    final sum = _ratings!.fold(
        0,
        (sum, rating) =>
            sum + (isService ? rating.serviceVote : rating.storeVote));
    return sum / _ratings!.length;
  }

  Map<String, Map<int, int>> getRatingDistribution() {
    final distribution = {
      'service': <int, int>{},
      'store': <int, int>{},
    };

    if (_ratings == null || _ratings!.isEmpty) {
      return distribution;
    }

    // Initialize counters for all possible ratings
    for (int i = 1; i <= 5; i++) {
      distribution['service']![i] = 0;
      distribution['store']![i] = 0;
    }

    for (var rating in _ratings!) {
      // Count service votes
      distribution['service']![rating.serviceVote] =
          (distribution['service']![rating.serviceVote] ?? 0) + 1;

      // Count store votes
      distribution['store']![rating.storeVote] =
          (distribution['store']![rating.storeVote] ?? 0) + 1;
    }

    return distribution;
  }
}

final bookingRatingController =
    StateNotifierProvider<BookingRatingController, bool>(
        (ref) => BookingRatingController(ref));

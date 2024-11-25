import 'package:fluffypawuser/models/tracking/tracking_file_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluffypawuser/services/tracking_service_provider.dart';

class TrackingController extends StateNotifier<AsyncValue<List<TrackingInfo>>> {
  final Ref ref;
  final int bookingId;
  
  TrackingController(this.ref, this.bookingId) : super(const AsyncValue.loading()) {
    getAllTrackingByBookingId();
  }

  Future<void> getAllTrackingByBookingId() async {
    try {
      state = const AsyncValue.loading();
      
      final response = await ref
          .read(trackingServiceProvider)
          .getAllTrackingByBookingId(bookingId);

      // Return empty list for 404 status
      if (response.statusCode == 404) {
        state = const AsyncValue.data([]);
        debugPrint('No tracking updates found for booking $bookingId');
        return;
      }

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> trackingList = response.data['data'];
        final List<TrackingInfo> trackings = trackingList
            .map((tracking) => TrackingInfo.fromMap(Map<String, dynamic>.from(tracking)))
            .toList();

        // Sort by uploadDate descending (newest first)
        trackings.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));

        state = AsyncValue.data(trackings);
        
        // Debug log
        debugPrint('Loaded ${trackings.length} tracking updates for booking $bookingId');
        trackings.forEach((tracking) {
          debugPrint(
            'Tracking ID: ${tracking.id}, '
            'Description: ${tracking?.description}, '
            'Files: ${tracking.files.length}, '
            'Date: ${tracking.uploadDate}'
          );
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load tracking updates');
      }
    } catch (e, stack) {
      debugPrint('Error getting tracking updates: $e');
      if (e.toString().contains('404')) {
        state = const AsyncValue.data([]);
      } else {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final trackingControllerProvider = StateNotifierProvider.family<TrackingController, AsyncValue<List<TrackingInfo>>, int>(
  (ref, bookingId) => TrackingController(ref, bookingId),
);
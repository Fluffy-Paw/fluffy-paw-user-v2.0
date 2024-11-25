import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class TrackingProvider {
  Future<Response> getAllTrackingByBookingId(int bookingId);
}

class TrackingServiceProvider implements TrackingProvider {
  final Ref ref;

  TrackingServiceProvider(this.ref);

  @override
  Future<Response> getAllTrackingByBookingId(int bookingId) async {
    final response = await ref
        .read(apiClientProvider)
        .get('${AppConstants.getAllTrackingByBookingId}/$bookingId');
    return response;
  }
}

final trackingServiceProvider = Provider((ref) => TrackingServiceProvider(ref));
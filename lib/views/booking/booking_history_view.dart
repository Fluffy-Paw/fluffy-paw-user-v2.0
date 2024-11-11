import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/views/booking/components/booking_history_layout.dart';
import 'package:fluffypawuser/views/store/layouts/booking_confirmation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingHistoryView extends ConsumerWidget {
  const BookingHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNewBooking = ref.watch(hasNewBookingProvider);
    return BookingHistoryLayout(hasNewBooking: hasNewBooking);
  }
}
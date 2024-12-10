import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:flutter/material.dart';

class ChoosePetForBookingView extends StatelessWidget {
  final BookingDataModel bookingData;
  const ChoosePetForBookingView({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChoosePetForBookingLayout(bookingData: bookingData),
    );
  }
}
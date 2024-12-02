import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:flutter/material.dart';

class ChoosePetForBookingView extends StatelessWidget {
  final int serviceTypeId;
  final int timeSlotId;
  final int storeId;
  const ChoosePetForBookingView({super.key, required this.serviceTypeId,required this.timeSlotId, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChoosePetForBookingLayout(serviceTypeId: serviceTypeId, timeSlotId: timeSlotId, storeId: storeId,),
    );
  }
}
import 'package:fluffypawuser/views/store/layouts/store_detail_layout.dart';
import 'package:flutter/material.dart';

class StoreDetailView extends StatelessWidget {
  final int serviceTypeId;
  final int? isFromBookingScreen;
  
  const StoreDetailView({
    super.key, 
    required this.serviceTypeId, 
    this.isFromBookingScreen,
  });

  @override
  Widget build(BuildContext context) {
    return StoreDetailLayout(
      storeId: serviceTypeId,  // Using serviceTypeId as storeId
      isFromBookingScreen: isFromBookingScreen,
    );
  }
}
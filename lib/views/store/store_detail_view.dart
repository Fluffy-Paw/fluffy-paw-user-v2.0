import 'package:fluffypawuser/views/store/layouts/store_detail_layout.dart';
import 'package:flutter/material.dart';

class StoreDetailView extends StatelessWidget {
  final int serviceTypeId;
  
  const StoreDetailView({super.key, required this.serviceTypeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreDetailLayout(storeId: serviceTypeId),
    );
  }
}
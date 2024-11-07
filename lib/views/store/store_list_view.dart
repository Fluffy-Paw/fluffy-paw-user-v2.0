import 'package:fluffypawuser/views/store/layouts/store_list_by_service_layout.dart';
import 'package:flutter/material.dart';

class StoreListView extends StatelessWidget {
  final int serviceTypeId;
  final String serviceTypeName;
  const StoreListView({super.key, required this.serviceTypeId, required this.serviceTypeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreListByServiceLayout(serviceTypeId: serviceTypeId, serviceTypeName: serviceTypeName,),
    );
  }
}
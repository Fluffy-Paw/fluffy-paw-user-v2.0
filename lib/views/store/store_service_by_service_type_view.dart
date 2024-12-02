import 'package:fluffypawuser/views/store/layouts/store_service_by_type_layoute.dart';
import 'package:flutter/material.dart';

class StoreServiceByServiceTypeView extends StatelessWidget {
  final int serviceTypeId;
  final String serviceTypeName;
  const StoreServiceByServiceTypeView({super.key, required this.serviceTypeId, required this.serviceTypeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreServiceListLayout(serviceTypeId: serviceTypeId, serviceTypeName: serviceTypeName,),
    );
  }
}
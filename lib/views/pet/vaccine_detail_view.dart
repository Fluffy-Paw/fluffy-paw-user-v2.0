import 'package:fluffypawuser/views/pet/layouts/vaccine_detail_layout.dart';
import 'package:flutter/material.dart';

class VaccineDetailView extends StatelessWidget {
  final int id;
  const VaccineDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VaccineDetailLayout(vaccineId: id,),
    );
  }
}
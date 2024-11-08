import 'package:fluffypawuser/views/pet/layouts/add_vaccine_layout.dart';
import 'package:flutter/material.dart';

class AddVaccineView extends StatelessWidget {
  final int id;
  const AddVaccineView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddVaccineLayout(petId: id,),
    );
  }
}
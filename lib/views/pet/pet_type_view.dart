import 'package:fluffypawuser/views/pet/layouts/pet_type_layout.dart';
import 'package:flutter/material.dart';

class PetTypeView extends StatelessWidget {
  const PetTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PetTypeSelect(),
    );
  }
}

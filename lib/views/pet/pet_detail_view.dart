import 'package:fluffypawuser/views/pet/layouts/pet_detail_layout.dart';
import 'package:flutter/material.dart';

class PetDetailView extends StatelessWidget {
  final int petId;
  const PetDetailView({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PetDetailLayout(
      petId: petId,
    );
  }
}
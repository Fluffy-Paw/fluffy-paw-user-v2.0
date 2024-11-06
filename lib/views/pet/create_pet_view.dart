import 'package:fluffypawuser/views/pet/layouts/create_pet_layout.dart';
import 'package:flutter/material.dart';

class CreatePetView extends StatelessWidget {
  final int id;
  const CreatePetView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreatePetLayout(petType: id,),
    );
  }
}

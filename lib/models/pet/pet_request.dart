import 'dart:io';

import 'package:dio/dio.dart';

class PetRequest {
  final String name;
  final String description;
  final String sex;
  final String allergy;
  final int behaviorCategoryId;
  final bool isNeuter;
  final int petTypeId;
  final String dob;
  final double weight;
  final String microchipNumber;

  PetRequest({
    required this.name,
    required this.description,
    required this.sex,
    required this.allergy,
    required this.behaviorCategoryId,
    required this.isNeuter,
    required this.petTypeId,
    required this.dob,
    required this.weight,
    required this.microchipNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'Decription': description,
      'sex': sex,
      'allergy': allergy,
      'behavior_category_id': behaviorCategoryId,
      'is_neuter': isNeuter,
      'pet_type_id': petTypeId,
      'dob': dob,
      'weight': weight,
      'microchip_number': microchipNumber,
    };
  }


  // Factory constructor for creating a test instance
  factory PetRequest.test() {
    return PetRequest(
      name: 'Test Pet',
      description: 'Test Description',
      sex: "",
      allergy: "",
      behaviorCategoryId: 1,
      isNeuter: true,
      petTypeId: 1,
      dob: "",
      weight: 1.0,
      microchipNumber: '111'
    );
  }
}
import 'dart:io';

import 'package:dio/dio.dart';

class VaccineRequest {
  final int petId;
  final String name;
  final File vaccineImage;
  final int petCurrentWeight;
  final String vaccineDate;
  final String nextVaccineDate;
  final String description;

  VaccineRequest({
    required this.petId,
    required this.name,
    required this.vaccineImage,
    required this.petCurrentWeight,
    required this.vaccineDate,
    required this.nextVaccineDate,
    required this.description,
  });

  // Hàm để tạo dữ liệu form-data cho yêu cầu POST
  Map<String, dynamic> toFormData() {
    return {
      'PetId': petId.toString(),
      'Name': name,
      'VaccineImage': MultipartFile.fromFileSync(
        vaccineImage.path,
        filename: vaccineImage.path.split('/').last,
        contentType: DioMediaType('image', 'png'),
      ),
      'PetCurrentWeight': petCurrentWeight.toString(),
      'VaccineDate': vaccineDate,
      'NextVaccineDate': nextVaccineDate,
      'Description': description,
    };
  }
}

import 'dart:io';

import 'package:dio/dio.dart';

class UpdateUserModel {
  final String fullName;
  final String gender;
  final String phone;
  final String address;
  final String email;
  final String dob;
  final File? avatar;

  UpdateUserModel({
    required this.fullName,
    required this.gender,
    required this.phone,
    required this.address,
    required this.email,
    required this.dob,
    this.avatar,
  });

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'FullName': fullName,
      'Gender': gender,
      'Phone': phone,
      'Address': address,
      'Email': email,
      'Dob': dob,
    });

    if (avatar != null) {
      String fileName = avatar!.path.split('/').last;
      formData.files.add(MapEntry(
        'Avatar',
        await MultipartFile.fromFile(
          avatar!.path,
          filename: fileName,
        ),
      ));
    }

    return formData;
  }
}
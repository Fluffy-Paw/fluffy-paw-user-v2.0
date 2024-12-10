import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Kiểm tra xem service location có được bật không
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng bật dịch vụ định vị trên thiết bị')));
    return false;
  }

  // Kiểm tra quyền truy cập vị trí
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')));
      return false;
    }
  }

  // Nếu quyền bị từ chối vĩnh viễn
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Quyền truy cập vị trí bị từ chối vĩnh viễn, vui lòng cấp quyền trong Cài đặt')));
    return false;
  }

  return true;
}
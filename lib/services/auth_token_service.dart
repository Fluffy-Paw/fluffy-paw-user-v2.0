import 'dart:convert';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthTokenService {
  final Ref ref;

  AuthTokenService(this.ref);

  Future<String?> getCurrentUserId() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) return null;
      
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(resp);

      return map['id']?.toString();
    } catch (e) {
      print('Error getting user ID from token: $e');
      return null;
    }
  }
}

final authTokenServiceProvider = Provider((ref) => AuthTokenService(ref));
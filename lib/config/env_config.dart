import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: "assets/env/api_key.env");
  }

  static String get goongMapKey {
    final key = dotenv.env['GOONG_MAP_KEY'];
    if (key == null) throw Exception('GOONG_MAP_KEY not found in .env file');
    return key;
  }
  
  static String get goongApiKey {
    final key = dotenv.env['GOONG_API_KEY'];
    if (key == null) throw Exception('GOONG_API_KEY not found in .env file');
    return key;
  }
}
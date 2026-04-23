import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing env key: $key');
    }
    return value;
  }
}

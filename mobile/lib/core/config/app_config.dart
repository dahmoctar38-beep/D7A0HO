import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Base URL for the NutriScan gateway.
  ///
  /// Priority (first non-empty wins):
  /// 1. Compile-time --dart-define=API_BASE_URL=...
  /// 2. Platform defaults below
  static String get apiBaseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;

    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator loopback
      return 'http://10.0.2.2:8000';
    }
    // iOS simulator / macOS
    return 'http://localhost:8000';
  }
}

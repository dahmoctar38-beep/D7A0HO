import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient._();

  static Dio build() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (_) {}, // silent in prod; swap for logger in dev
        ),
      );
  }
}

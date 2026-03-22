import 'package:dio/dio.dart';
import '../domain/analysis_result.dart';
import '../domain/analysis_service.dart';
import '../../product_details/domain/product.dart';

class HttpAnalysisService implements AnalysisService {
  final Dio _dio;
  HttpAnalysisService(this._dio);

  @override
  Future<AnalysisResult> analyze(Product product) async {
    // Gateway exposes GET /v1/analysis/{barcode} — no need to POST product body.
    final response = await _dio.get('/v1/analysis/${product.barcode}');
    return AnalysisResult.fromJson(response.data as Map<String, dynamic>);
  }
}

import 'package:dio/dio.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

class HttpProductRepository implements ProductRepository {
  final Dio _dio;
  HttpProductRepository(this._dio);

  @override
  Future<Product?> findByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/v1/products/$barcode');
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

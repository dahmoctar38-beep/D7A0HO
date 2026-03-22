import 'product.dart';

abstract class ProductRepository {
  Future<Product?> findByBarcode(String barcode);
}

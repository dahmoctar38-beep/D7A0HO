import '../../product_details/domain/product.dart';
import 'analysis_result.dart';

abstract class AnalysisService {
  Future<AnalysisResult> analyze(Product product);
}

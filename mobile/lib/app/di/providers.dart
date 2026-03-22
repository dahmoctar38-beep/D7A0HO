import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/product_details/domain/product.dart';
import '../../features/product_details/domain/product_repository.dart';
import '../../features/product_details/data/mock_product_repository.dart';
import '../../features/product_details/data/http_product_repository.dart';
import '../../features/ai_analysis/domain/analysis_result.dart';
import '../../features/ai_analysis/domain/analysis_service.dart';
import '../../features/ai_analysis/data/mock_analysis_service.dart';
import '../../features/ai_analysis/data/http_analysis_service.dart';
import '../../features/scanner/domain/scanner_service.dart';
import '../../features/scanner/data/mock_scanner_service.dart';
import '../../features/auth/domain/auth_service.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/data/mock_auth_service.dart';
import '../../features/profile/domain/user_preferences.dart';
import '../../features/profile/data/preferences_service.dart';
import '../../features/history/domain/scan_record.dart';
import '../../features/history/data/history_service.dart';
import '../../features/favorites/data/favorites_service.dart';

const _useRealApi = bool.fromEnvironment('USE_REAL_API', defaultValue: false);

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final dioProvider = Provider<Dio>((_) => ApiClient.build());

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

final authServiceProvider = Provider<AuthService>((_) => MockAuthService());

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final svc = ref.read(authServiceProvider);
  if (svc is MockAuthService) return (await MockAuthService.create()).currentUser;
  return svc.currentUser;
});

// ---------------------------------------------------------------------------
// Services — mock vs. HTTP
// ---------------------------------------------------------------------------

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (_useRealApi) return HttpProductRepository(ref.read(dioProvider));
  return MockProductRepository();
});

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  if (_useRealApi) return HttpAnalysisService(ref.read(dioProvider));
  return MockAnalysisService();
});

final scannerServiceProvider = Provider<ScannerService>(
  (_) => MockScannerService(),
);

// ---------------------------------------------------------------------------
// Preferences
// ---------------------------------------------------------------------------

final preferencesServiceProvider =
    Provider<PreferencesService>((_) => PreferencesService());

final userPreferencesProvider = FutureProvider<UserPreferences>((ref) {
  return ref.read(preferencesServiceProvider).load();
});

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

final historyServiceProvider =
    Provider<HistoryService>((_) => HistoryService());

final scanHistoryProvider = FutureProvider<List<ScanRecord>>((ref) {
  return ref.read(historyServiceProvider).load();
});

// ---------------------------------------------------------------------------
// Favorites
// ---------------------------------------------------------------------------

final favoritesServiceProvider =
    Provider<FavoritesService>((_) => FavoritesService());

final favoritesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(favoritesServiceProvider).loadBarcodes();
});

final isFavoriteProvider =
    FutureProvider.family<bool, String>((ref, barcode) async {
  final barcodes = await ref.watch(favoritesProvider.future);
  return barcodes.contains(barcode);
});

// ---------------------------------------------------------------------------
// Product state
// ---------------------------------------------------------------------------

final productProvider =
    FutureProvider.family<Product?, String>((ref, barcode) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.findByBarcode(barcode);
});

// ---------------------------------------------------------------------------
// Analysis state
// ---------------------------------------------------------------------------

final analysisProvider =
    FutureProvider.family<AnalysisResult, String>((ref, barcode) async {
  final product = await ref.watch(productProvider(barcode).future);
  if (product == null) {
    throw Exception('Product not found for barcode $barcode');
  }
  final service = ref.read(analysisServiceProvider);
  return service.analyze(product);
});

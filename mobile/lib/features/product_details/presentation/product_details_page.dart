import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_loading.dart';
import '../../../core/widgets/ns_error.dart';
import '../domain/product.dart';
import '../../history/domain/scan_record.dart';

class ProductDetailsPage extends ConsumerWidget {
  final String barcode;
  const ProductDetailsPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(barcode));
    final isFavAsync = ref.watch(isFavoriteProvider(barcode));
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.productDetailsTitle),
        actions: [
          isFavAsync.when(
            data: (isFav) => IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppTheme.danger : null,
              ),
              onPressed: () async {
                await ref.read(favoritesServiceProvider).toggle(barcode);
                ref.invalidate(isFavoriteProvider(barcode));
                ref.invalidate(favoritesProvider);
              },
            ),
            loading: () => const SizedBox(width: 48),
            error: (e, _) => const SizedBox(width: 48),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const NsLoading(message: 'Loading product…'),
        error: (e, _) => NsError(
          message: AppStrings.errorProductNotFound,
          onRetry: () => ref.invalidate(productProvider(barcode)),
        ),
        data: (product) {
          if (product == null) {
            return NsError(
              message: AppStrings.errorProductNotFound,
              onRetry: () => ref.invalidate(productProvider(barcode)),
            );
          }
          // Record in history (fire-and-forget, score resolved later)
          _saveHistory(ref, product);
          return _ProductBody(product: product);
        },
      ),
    );
  }

  void _saveHistory(WidgetRef ref, Product product) {
    // We don't have the score here without running analysis,
    // so use a neutral placeholder. Analysis page writes the real score.
    final record = ScanRecord(
      barcode: product.barcode,
      productName: product.name,
      brand: product.brand,
      healthScore: 0,
      scannedAt: DateTime.now(),
    );
    ref.read(historyServiceProvider).add(record);
    ref.invalidate(scanHistoryProvider);
  }
}

class _ProductBody extends StatelessWidget {
  final Product product;
  const _ProductBody({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductHeader(product: product),
          const SizedBox(height: 16),
          _NutritionCard(nutrition: product.nutrition),
          const SizedBox(height: 16),
          if (product.allergens.isNotEmpty) ...[
            _AllergenCard(allergens: product.allergens),
            const SizedBox(height: 16),
          ],
          _IngredientsCard(ingredients: product.ingredients),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(
              AppRoutes.aiAnalysisPath(product.barcode),
            ),
            icon: const Icon(Icons.psychology),
            label: const Text('View AI Analysis'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final Product product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (product.nutriscore != null) ...[
                    const SizedBox(height: 8),
                    _NutriScoreBadge(score: product.nutriscore!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutriScoreBadge extends StatelessWidget {
  final String score;
  const _NutriScoreBadge({required this.score});

  Color get _color {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF1B8A3E);
      case 'B':
        return const Color(0xFF6FB53C);
      case 'C':
        return const Color(0xFFFFCC00);
      case 'D':
        return const Color(0xFFFF7C00);
      default:
        return const Color(0xFFE63312);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Nutri-Score $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionFacts nutrition;
  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Facts (per 100g)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Divider(),
            _NutritionRow('Calories', '${nutrition.calories} kcal',
                bold: true),
            _NutritionRow('Protein', '${nutrition.protein}g'),
            _NutritionRow('Carbohydrates', '${nutrition.carbohydrates}g'),
            _NutritionRow(
              '  of which sugar',
              '${nutrition.sugar}g',
              indent: true,
              warn: nutrition.sugar > 20,
            ),
            _NutritionRow('Fat', '${nutrition.fat}g'),
            _NutritionRow(
              '  of which saturates',
              '${nutrition.saturatedFat}g',
              indent: true,
              warn: nutrition.saturatedFat > 10,
            ),
            _NutritionRow('Dietary Fiber', '${nutrition.fiber}g'),
            _NutritionRow(
              'Sodium',
              '${nutrition.sodium}g',
              warn: nutrition.sodium > 0.6,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool indent;
  final bool bold;
  final bool warn;

  const _NutritionRow(
    this.label,
    this.value, {
    this.indent = false,
    this.bold = false,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : warn
            ? const TextStyle(color: AppTheme.warning)
            : null;
    return Padding(
      padding: EdgeInsets.only(
        top: 6,
        bottom: 6,
        left: indent ? 12 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _AllergenCard extends StatelessWidget {
  final List<String> allergens;
  const _AllergenCard({required this.allergens});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.danger.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppTheme.danger, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Allergen Warning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.danger,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: allergens
                  .map((a) => Chip(
                        label: Text(a),
                        backgroundColor:
                            AppTheme.danger.withValues(alpha: 0.1),
                        labelStyle:
                            const TextStyle(color: AppTheme.danger, fontSize: 12),
                        side: BorderSide(
                            color: AppTheme.danger.withValues(alpha: 0.3)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<String> ingredients;
  const _IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              ingredients.join(', '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

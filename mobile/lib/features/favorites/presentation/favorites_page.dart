import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_empty.dart';
import '../../../core/widgets/ns_loading.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: barcodesAsync.when(
        loading: () => const NsLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (barcodes) => barcodes.isEmpty
            ? NsEmpty(
                icon: Icons.favorite_border,
                message: 'No favorites yet.',
                action: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.scanner),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan a product'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: barcodes.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final barcode = barcodes[i];
                  return Card(
                    child: ListTile(
                      onTap: () => context.push(
                        AppRoutes.productDetailsPath(barcode),
                      ),
                      leading: const Icon(Icons.favorite,
                          color: AppTheme.danger),
                      title: Text(barcode,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.textSecondary),
                        onPressed: () async {
                          await ref
                              .read(favoritesServiceProvider)
                              .toggle(barcode);
                          ref.invalidate(favoritesProvider);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

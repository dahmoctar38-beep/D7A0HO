import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_empty.dart';
import '../../../core/widgets/ns_loading.dart';
import '../domain/scan_record.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          historyAsync.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear history',
                    onPressed: () async {
                      await ref.read(historyServiceProvider).clear();
                      ref.invalidate(scanHistoryProvider);
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const NsLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (records) => records.isEmpty
            ? const NsEmpty(
                icon: Icons.history,
                message: 'No scans yet. Start scanning products!',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _ScanRecordTile(record: records[i]),
              ),
      ),
    );
  }
}

class _ScanRecordTile extends StatelessWidget {
  final ScanRecord record;
  const _ScanRecordTile({required this.record});

  Color get _scoreColor {
    if (record.healthScore >= 85) return AppTheme.safe;
    if (record.healthScore >= 70) return AppTheme.primaryLight;
    if (record.healthScore >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push(
          AppRoutes.productDetailsPath(record.barcode),
        ),
        leading: CircleAvatar(
          backgroundColor: _scoreColor.withValues(alpha: 0.15),
          child: Text(
            '${record.healthScore}',
            style: TextStyle(
              color: _scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(record.productName,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${record.brand} · ${_formatDate(record.scannedAt)}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

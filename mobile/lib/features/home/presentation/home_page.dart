import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/legal_disclaimer.dart';
import '../../../core/widgets/ns_empty.dart';
import '../../../app/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Column(
        children: [
          const LegalDisclaimer(),
          Expanded(
            child: NsEmpty(
              icon: Icons.qr_code_scanner,
              message: AppStrings.emptyNoScans,
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.scanner),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan a Product'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.scanner),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
    );
  }
}

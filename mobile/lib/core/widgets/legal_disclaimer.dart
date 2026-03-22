import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../constants/app_constants.dart';

class LegalDisclaimer extends StatelessWidget {
  const LegalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.disclaimerText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.warning.withValues(alpha: 0.9),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

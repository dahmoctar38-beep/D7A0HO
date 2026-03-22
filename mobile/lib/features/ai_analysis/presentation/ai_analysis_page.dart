import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_loading.dart';
import '../../../core/widgets/ns_error.dart';
import '../../../core/widgets/legal_disclaimer.dart';
import '../domain/analysis_result.dart';

class AiAnalysisPage extends ConsumerWidget {
  final String barcode;
  const AiAnalysisPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(analysisProvider(barcode));
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aiAnalysisTitle)),
      body: resultAsync.when(
        loading: () => const NsLoading(message: 'Analysing with AI…'),
        error: (e, _) => NsError(
          message: e.toString(),
          onRetry: () => ref.invalidate(analysisProvider(barcode)),
        ),
        data: (result) => _AnalysisBody(result: result),
      ),
    );
  }
}

class _AnalysisBody extends StatelessWidget {
  final AnalysisResult result;
  const _AnalysisBody({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HealthScoreCard(result: result),
          const SizedBox(height: 16),
          _SummaryCard(summary: result.summary),
          const SizedBox(height: 16),
          if (result.highlights.isNotEmpty)
            _PointsCard(
              title: 'Highlights',
              points: result.highlights,
              color: AppTheme.safe,
              icon: Icons.check_circle_outline,
            ),
          if (result.concerns.isNotEmpty) ...[
            const SizedBox(height: 16),
            _PointsCard(
              title: 'Concerns',
              points: result.concerns,
              color: AppTheme.danger,
              icon: Icons.cancel_outlined,
            ),
          ],
          const SizedBox(height: 16),
          _DiabeticCard(flag: result.diabeticFlag),
          if (result.allergenWarnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AllergenCard(warnings: result.allergenWarnings),
          ],
          if (result.alternatives.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AlternativesCard(alternatives: result.alternatives),
          ],
          const SizedBox(height: 16),
          const LegalDisclaimer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  final AnalysisResult result;
  const _HealthScoreCard({required this.result});

  Color get _verdictColor {
    switch (result.verdict) {
      case HealthVerdict.excellent:
        return AppTheme.safe;
      case HealthVerdict.good:
        return AppTheme.primaryLight;
      case HealthVerdict.moderate:
        return AppTheme.warning;
      case HealthVerdict.poor:
        return Colors.deepOrange;
      case HealthVerdict.avoid:
        return AppTheme.danger;
    }
  }

  String get _verdictLabel {
    switch (result.verdict) {
      case HealthVerdict.excellent:
        return 'Excellent';
      case HealthVerdict.good:
        return 'Good';
      case HealthVerdict.moderate:
        return 'Moderate';
      case HealthVerdict.poor:
        return 'Poor';
      case HealthVerdict.avoid:
        return 'Avoid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Health Score',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: result.healthScore / 100,
                    strokeWidth: 10,
                    backgroundColor: AppTheme.divider,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_verdictColor),
                  ),
                ),
                Text(
                  '${result.healthScore}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _verdictColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _verdictColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _verdictLabel,
                style: TextStyle(
                  color: _verdictColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.psychology, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final String title;
  final List<String> points;
  final Color color;
  final IconData icon;
  const _PointsCard({
    required this.title,
    required this.points,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...points.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiabeticCard extends StatelessWidget {
  final DiabeticFlag flag;
  const _DiabeticCard({required this.flag});

  Color get _riskColor {
    switch (flag.risk) {
      case RiskLevel.none:
        return AppTheme.safe;
      case RiskLevel.low:
        return AppTheme.primaryLight;
      case RiskLevel.medium:
        return AppTheme.warning;
      case RiskLevel.high:
        return AppTheme.danger;
    }
  }

  String get _riskLabel {
    switch (flag.risk) {
      case RiskLevel.none:
        return 'Safe';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _riskColor.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _riskColor.withValues(alpha: 0.3)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: _riskColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Diabetic Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _riskLabel,
                    style: TextStyle(
                      color: _riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              flag.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergenCard extends StatelessWidget {
  final List<AllergenWarning> warnings;
  const _AllergenCard({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allergen Warnings',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...warnings.map((w) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber,
                          color: AppTheme.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(w.note,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _AlternativesCard extends StatelessWidget {
  final List<Alternative> alternatives;
  const _AlternativesCard({required this.alternatives});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Healthier Alternatives',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...alternatives.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.swap_horiz,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w500),
                            ),
                            Text(
                              a.reason,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

import '../../product_details/domain/product.dart';
import '../domain/analysis_result.dart';
import '../domain/analysis_service.dart';

class MockAnalysisService implements AnalysisService {
  @override
  Future<AnalysisResult> analyze(Product product) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _buildResult(product);
  }

  AnalysisResult _buildResult(Product product) {
    final n = product.nutrition;
    final score = _score(n);
    final verdict = _verdict(score);
    final diabeticRisk = _diabeticRisk(n);

    return AnalysisResult(
      barcode: product.barcode,
      verdict: verdict,
      healthScore: score,
      summary: _summary(product.name, verdict),
      highlights: _highlights(n),
      concerns: _concerns(n),
      diabeticFlag: diabeticRisk,
      allergenWarnings: product.allergens
          .map((a) => AllergenWarning(
                allergen: a,
                note: 'This product contains $a. Avoid if allergic.',
              ))
          .toList(),
      alternatives: _alternatives(verdict),
    );
  }

  int _score(NutritionFacts n) {
    var score = 100;
    if (n.sugar > 20) {
      score -= 30;
    } else if (n.sugar > 10) {
      score -= 15;
    } else if (n.sugar > 5) {
      score -= 5;
    }
    if (n.saturatedFat > 10) {
      score -= 20;
    } else if (n.saturatedFat > 5) {
      score -= 15;
    }
    if (n.sodium > 0.6) score -= 15;
    if (n.sugar > 5 && n.protein == 0 && n.fiber == 0) score -= 20;
    if (n.fiber > 5) score += 10;
    if (n.protein > 10) score += 5;
    if (n.calories > 450) score -= 10;
    return score.clamp(0, 100);
  }

  HealthVerdict _verdict(int score) {
    if (score >= 85) return HealthVerdict.excellent;
    if (score >= 70) return HealthVerdict.good;
    if (score >= 50) return HealthVerdict.moderate;
    if (score >= 30) return HealthVerdict.poor;
    return HealthVerdict.avoid;
  }

  DiabeticFlag _diabeticRisk(NutritionFacts n) {
    if (n.sugar > 30) {
      return const DiabeticFlag(
        risk: RiskLevel.high,
        explanation:
            'Very high sugar content. Strongly avoid if you have diabetes.',
      );
    } else if (n.sugar > 12) {
      return const DiabeticFlag(
        risk: RiskLevel.medium,
        explanation:
            'Moderate sugar. Consume with caution if you have diabetes.',
      );
    } else if (n.sugar > 5) {
      return const DiabeticFlag(
        risk: RiskLevel.low,
        explanation: 'Low-to-moderate sugar. Monitor portion size.',
      );
    }
    return const DiabeticFlag(
      risk: RiskLevel.none,
      explanation: 'Minimal sugar content. Generally safe for diabetics.',
    );
  }

  List<String> _highlights(NutritionFacts n) {
    final h = <String>[];
    if (n.protein >= 10) h.add('Good source of protein (${n.protein}g)');
    if (n.fiber >= 5) h.add('High in dietary fiber (${n.fiber}g)');
    if (n.sugar <= 5) h.add('Low in sugar (${n.sugar}g)');
    if (n.saturatedFat <= 2) h.add('Low saturated fat');
    if (n.sodium <= 0.1) h.add('Very low sodium');
    if (h.isEmpty) h.add('Check portion size for balanced consumption');
    return h;
  }

  List<String> _concerns(NutritionFacts n) {
    final c = <String>[];
    if (n.sugar > 20) c.add('Very high sugar (${n.sugar}g per 100g)');
    if (n.saturatedFat > 10) c.add('High saturated fat (${n.saturatedFat}g)');
    if (n.sodium > 0.6) c.add('High sodium (${n.sodium}g) — risk for hypertension');
    if (n.calories > 450) c.add('High calorie density (${n.calories} kcal)');
    return c;
  }

  String _summary(String name, HealthVerdict v) {
    switch (v) {
      case HealthVerdict.excellent:
        return '$name is an excellent choice with well-balanced nutrition.';
      case HealthVerdict.good:
        return '$name is a good choice for most people in moderate amounts.';
      case HealthVerdict.moderate:
        return '$name has some nutritional concerns. Consume occasionally.';
      case HealthVerdict.poor:
        return '$name has significant nutritional issues. Limit consumption.';
      case HealthVerdict.avoid:
        return '$name is not recommended for regular consumption.';
    }
  }

  List<Alternative> _alternatives(HealthVerdict v) {
    if (v == HealthVerdict.excellent || v == HealthVerdict.good) return [];
    return const [
      Alternative(
        name: 'Whole grain alternatives',
        reason: 'Higher fiber, more balanced nutrition',
      ),
      Alternative(
        name: 'Fresh fruit',
        reason: 'Natural sugars with vitamins and fiber',
      ),
    ];
  }
}

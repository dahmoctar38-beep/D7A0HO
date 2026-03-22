enum HealthVerdict { excellent, good, moderate, poor, avoid }

enum RiskLevel { none, low, medium, high }

class DiabeticFlag {
  final RiskLevel risk;
  final String explanation;
  const DiabeticFlag({required this.risk, required this.explanation});

  factory DiabeticFlag.fromJson(Map<String, dynamic> j) => DiabeticFlag(
        risk: RiskLevel.values.byName(j['risk'] as String),
        explanation: j['explanation'] as String,
      );
}

class AllergenWarning {
  final String allergen;
  final String note;
  const AllergenWarning({required this.allergen, required this.note});

  factory AllergenWarning.fromJson(Map<String, dynamic> j) => AllergenWarning(
        allergen: j['allergen'] as String,
        note: j['note'] as String,
      );
}

class Alternative {
  final String name;
  final String reason;
  const Alternative({required this.name, required this.reason});

  factory Alternative.fromJson(Map<String, dynamic> j) => Alternative(
        name: j['name'] as String,
        reason: j['reason'] as String,
      );
}

class AnalysisResult {
  final String barcode;
  final HealthVerdict verdict;
  final int healthScore;
  final String summary;
  final List<String> highlights;
  final List<String> concerns;
  final DiabeticFlag diabeticFlag;
  final List<AllergenWarning> allergenWarnings;
  final List<Alternative> alternatives;

  const AnalysisResult({
    required this.barcode,
    required this.verdict,
    required this.healthScore,
    required this.summary,
    required this.highlights,
    required this.concerns,
    required this.diabeticFlag,
    required this.allergenWarnings,
    required this.alternatives,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> j) => AnalysisResult(
        barcode: j['barcode'] as String,
        verdict: HealthVerdict.values.byName(j['verdict'] as String),
        healthScore: j['health_score'] as int,
        summary: j['summary'] as String,
        highlights: List<String>.from(j['highlights'] as List),
        concerns: List<String>.from(j['concerns'] as List),
        diabeticFlag:
            DiabeticFlag.fromJson(j['diabetic_flag'] as Map<String, dynamic>),
        allergenWarnings: (j['allergen_warnings'] as List)
            .map((e) => AllergenWarning.fromJson(e as Map<String, dynamic>))
            .toList(),
        alternatives: (j['alternatives'] as List)
            .map((e) => Alternative.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

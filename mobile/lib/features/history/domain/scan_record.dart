class ScanRecord {
  final String barcode;
  final String productName;
  final String brand;
  final int healthScore;
  final DateTime scannedAt;

  const ScanRecord({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.healthScore,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'productName': productName,
        'brand': brand,
        'healthScore': healthScore,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
        barcode: j['barcode'] as String,
        productName: j['productName'] as String,
        brand: j['brand'] as String,
        healthScore: j['healthScore'] as int,
        scannedAt: DateTime.parse(j['scannedAt'] as String),
      );
}

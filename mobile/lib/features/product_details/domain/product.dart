class NutritionFacts {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double sugar;
  final double fat;
  final double saturatedFat;
  final double fiber;
  final double sodium;

  const NutritionFacts({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.sugar,
    required this.fat,
    required this.saturatedFat,
    required this.fiber,
    required this.sodium,
  });

  factory NutritionFacts.fromJson(Map<String, dynamic> j) => NutritionFacts(
        calories: (j['calories'] as num).toDouble(),
        protein: (j['protein'] as num).toDouble(),
        carbohydrates: (j['carbohydrates'] as num).toDouble(),
        sugar: (j['sugar'] as num).toDouble(),
        fat: (j['fat'] as num).toDouble(),
        saturatedFat: (j['saturated_fat'] as num).toDouble(),
        fiber: (j['fiber'] as num).toDouble(),
        sodium: (j['sodium'] as num).toDouble(),
      );
}

class Product {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final NutritionFacts nutrition;
  final List<String> ingredients;
  final List<String> allergens;
  final String? nutriscore;

  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.nutrition,
    required this.ingredients,
    required this.allergens,
    this.nutriscore,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        barcode: j['barcode'] as String,
        name: j['name'] as String,
        brand: j['brand'] as String,
        imageUrl: j['image_url'] as String?,
        nutrition:
            NutritionFacts.fromJson(j['nutrition'] as Map<String, dynamic>),
        ingredients: List<String>.from(j['ingredients'] as List),
        allergens: List<String>.from(j['allergens'] as List),
        nutriscore: j['nutriscore'] as String?,
      );
}

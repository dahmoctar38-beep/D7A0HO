import '../domain/product.dart';
import '../domain/product_repository.dart';

class MockProductRepository implements ProductRepository {
  static final _products = <String, Product>{
    '6281006530015': const Product(
      barcode: '6281006530015',
      name: 'Almarai Full Fat Milk',
      brand: 'Almarai',
      nutriscore: 'B',
      nutrition: NutritionFacts(
        calories: 62,
        protein: 3.2,
        carbohydrates: 4.8,
        sugar: 4.8,
        fat: 3.3,
        saturatedFat: 2.1,
        fiber: 0,
        sodium: 0.04,
      ),
      ingredients: ['Whole milk'],
      allergens: ['Milk'],
    ),
    '6281034000011': const Product(
      barcode: '6281034000011',
      name: 'Chips Oman Classic',
      brand: 'Oman Chips',
      nutriscore: 'D',
      nutrition: NutritionFacts(
        calories: 536,
        protein: 6.5,
        carbohydrates: 52,
        sugar: 0.5,
        fat: 34,
        saturatedFat: 14,
        fiber: 3.5,
        sodium: 0.9,
      ),
      ingredients: [
        'Potatoes',
        'Palm oil',
        'Salt',
        'Flavor enhancer (E621)',
      ],
      allergens: [],
    ),
    '5449000000996': const Product(
      barcode: '5449000000996',
      name: 'Coca-Cola Original',
      brand: 'Coca-Cola',
      nutriscore: 'E',
      nutrition: NutritionFacts(
        calories: 42,
        protein: 0,
        carbohydrates: 10.6,
        sugar: 10.6,
        fat: 0,
        saturatedFat: 0,
        fiber: 0,
        sodium: 0.01,
      ),
      ingredients: [
        'Carbonated water',
        'Sugar',
        'Caramel color (E150d)',
        'Phosphoric acid',
        'Natural flavors',
        'Caffeine',
      ],
      allergens: [],
    ),
    '6221012850014': const Product(
      barcode: '6221012850014',
      name: 'Quaker Oats',
      brand: 'Quaker',
      nutriscore: 'A',
      nutrition: NutritionFacts(
        calories: 367,
        protein: 13,
        carbohydrates: 58,
        sugar: 1.1,
        fat: 6.9,
        saturatedFat: 1.3,
        fiber: 10,
        sodium: 0.004,
      ),
      ingredients: ['100% whole grain oats'],
      allergens: ['Gluten'],
    ),
    '8712100325977': const Product(
      barcode: '8712100325977',
      name: 'Snickers Bar',
      brand: 'Mars',
      nutriscore: 'E',
      nutrition: NutritionFacts(
        calories: 488,
        protein: 8.2,
        carbohydrates: 60,
        sugar: 49,
        fat: 23,
        saturatedFat: 8.8,
        fiber: 1.6,
        sodium: 0.23,
      ),
      ingredients: [
        'Milk chocolate',
        'Sugar',
        'Peanuts',
        'Glucose syrup',
        'Skimmed milk powder',
        'Palm fat',
        'Butter',
      ],
      allergens: ['Milk', 'Peanuts', 'Soy'],
    ),
  };

  @override
  Future<Product?> findByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _products[barcode];
  }
}

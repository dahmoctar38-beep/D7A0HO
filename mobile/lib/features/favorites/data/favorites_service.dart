import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites';

  Future<List<String>> loadBarcodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> toggle(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.contains(barcode)) {
      list.remove(barcode);
    } else {
      list.add(barcode);
    }
    await prefs.setStringList(_key, list);
  }

  Future<bool> isFavorite(String barcode) async {
    final list = await loadBarcodes();
    return list.contains(barcode);
  }
}

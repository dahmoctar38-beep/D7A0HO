import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_preferences.dart';

class PreferencesService {
  static const _key = 'user_preferences';

  Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const UserPreferences();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserPreferences(
      isDiabetic: json['isDiabetic'] as bool? ?? false,
      isHypertensive: json['isHypertensive'] as bool? ?? false,
      allergens: List<String>.from(json['allergens'] as List? ?? []),
      veganMode: json['veganMode'] as bool? ?? false,
    );
  }

  Future<void> save(UserPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _key,
      jsonEncode({
        'isDiabetic': prefs.isDiabetic,
        'isHypertensive': prefs.isHypertensive,
        'allergens': prefs.allergens,
        'veganMode': prefs.veganMode,
      }),
    );
  }
}

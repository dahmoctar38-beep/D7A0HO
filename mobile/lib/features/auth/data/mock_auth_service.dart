import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_user.dart';
import '../domain/auth_service.dart';

class MockAuthService implements AuthService {
  static const _keyUserId = 'auth_user_id';
  static const _keyUserEmail = 'auth_user_email';

  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  static Future<MockAuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = MockAuthService();
    final id = prefs.getString(_keyUserId);
    final email = prefs.getString(_keyUserEmail);
    if (id != null && email != null) {
      service._current = AppUser(id: id, email: email);
    }
    return service;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final user = AppUser(id: 'mock-${email.hashCode}', email: email);
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserEmail, user.email);
    _current = user;
    return user;
  }

  @override
  Future<AppUser> register({required String email, required String password}) =>
      signIn(email: email, password: password);

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    _current = null;
  }
}

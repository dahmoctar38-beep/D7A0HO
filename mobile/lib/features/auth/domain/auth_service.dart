import 'app_user.dart';

abstract class AuthService {
  AppUser? get currentUser;
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> register({required String email, required String password});
  Future<void> signOut();
}

import '../models/models.dart';

abstract class AuthRepository {
  Stream<UserModel?> authStateChanges();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<UserModel> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}


import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRepository(auth, firestore);
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.uid,
    this.email,
    this.displayName,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? email,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      error: error,
    );
  }
}

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<String?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (displayName.trim().isEmpty) {
      return 'Please enter your name';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      final user = _auth.currentUser;
      if (user != null) {
        await _upsertUserProfile(user, displayName: displayName.trim());
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _mapAuthError(error);
    } catch (_) {
      return 'Registration failed. Please try again.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please enter email and password';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null) {
        await _upsertUserProfile(user);
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _mapAuthError(error);
    } catch (_) {
      return 'Login failed. Please try again.';
    }
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  Future<void> _upsertUserProfile(
    User user, {
    String? displayName,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': displayName ?? user.displayName ?? user.email ?? 'User',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._repo)
      : super(const AuthState(status: AuthStatus.unknown)) {
    _syncUser(_repo.currentUser);
    _subscription = _repo.authStateChanges().listen(_syncUser);
  }

  final AuthRepository _repo;
  StreamSubscription<User?>? _subscription;

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final error = await _repo.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (error != null) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: error,
      );
      return false;
    }
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final error = await _repo.login(email: email, password: password);
    if (error != null) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: error,
      );
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    await _repo.logout();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _syncUser(User? user) {
    if (user == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = AuthState(
      status: AuthStatus.authenticated,
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

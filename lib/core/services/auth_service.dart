import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

/// Authentication service for handling anonymous auth
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get user ID
  String? get userId => _auth.currentUser?.uid;

  /// Sign in anonymously
  /// 
  /// Creates a new anonymous user if not already signed in.
  /// Returns the User object on success.
  Future<User?> signInAnonymously() async {
    try {
      // If already signed in, return current user
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }

      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed', e.code);
    } catch (e) {
      throw AuthException('An unexpected error occurred', 'unknown');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account and all associated data
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // TODO: Delete user data from Firestore before deleting account
      await user.delete();
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

/// Custom auth exception
class AuthException implements Exception {
  AuthException(this.message, this.code);

  final String message;
  final String code;

  @override
  String toString() => 'AuthException: $message (code: $code)';
}


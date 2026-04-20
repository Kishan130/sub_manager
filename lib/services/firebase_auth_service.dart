import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Re-authenticates user with their current password (required before sensitive ops).
  Future<void> reauthenticate(String email, String password) async {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
  }

  /// Changes the password after successful re-authentication.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is signed in.');
    }
    // Re-authenticate first
    await reauthenticate(user.email!, currentPassword);
    // Then update password
    await user.updatePassword(newPassword);
  }

  /// Sends a password-reset email to the user's address.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Deletes the user account permanently after re-authentication.
  /// Returns true on success.
  Future<void> deleteAccount(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is signed in.');
    }
    await reauthenticate(user.email!, password);
    await user.delete();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseService _firebase = FirebaseService();

  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();
  User? get currentUser => _firebase.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _firebase.firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  Future<AppUser> signUpWithEmail(
      String email,
      String password,
      String username
      ) async {
    try {
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        username: username,
        profession: '',
        currency: '\$',
        darkMode: false,
        photoUrl: null,
        createdAt: DateTime.now(),
      );

      await _firebase.firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(appUser.toJson());

      await credential.user!.updateDisplayName(username);

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firebase.firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      final userData = doc.data();
      if (userData == null) {
        throw Exception('User data is null');
      }

      return AppUser.fromJson(userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _firebase.auth.signOut();
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
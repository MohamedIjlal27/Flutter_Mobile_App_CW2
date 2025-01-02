import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_travel/models/auth/auth_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Sign up failed');

      final userData = {
        'name': name,
        'email': email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImage': '',
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return AuthUser(
        uid: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Login failed');

      final userData = await _firestore.collection('users').doc(user.uid).get();

      if (!userData.exists) throw Exception('User data not found');

      return AuthUser.fromMap(userData.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final userData = await _firestore.collection('users').doc(user.uid).get();

      if (!userData.exists) return null;

      return AuthUser.fromMap(userData.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

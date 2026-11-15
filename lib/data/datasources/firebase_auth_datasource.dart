import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'auth_datasource.dart';

class FirebaseAuthDataSource implements IAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _getOrCreateProfile(credential.user!);
    } on FirebaseAuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user!;
      await firebaseUser.updateDisplayName(displayName.trim());
      final user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        displayName: displayName.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      await _users.doc(user.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        await _googleSignIn.initialize();
        final googleUser = await _googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(authCredential);
      }
      return await _getOrCreateProfile(credential.user!);
    } on FirebaseAuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw Exception(_authErrorMessage(error));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    return firebaseUser == null ? null : _getOrCreateProfile(firebaseUser);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    await _auth.currentUser?.updateDisplayName(user.displayName);
  }

  Future<UserModel> _getOrCreateProfile(User firebaseUser) async {
    final snapshot = await _users.doc(firebaseUser.uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromMap(snapshot.data()!, firebaseUser.uid);
    }

    final user = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      createdAt: DateTime.now(),
    );
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

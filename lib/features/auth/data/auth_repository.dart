import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({required String email, required String password, required String name});
  Future<UserModel?> signInWithGoogle();
  Future<UserModel> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({String? displayName, String? photoUrl});
  Future<void> deleteAccount();
  Stream<User?> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final user = UserModel.fromFirebaseUser(credential.user!);
    
    // Update last sign-in time in Firestore
    await _updateUserInFirestore(user);
    
    return user;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();
    
    final user = UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    
    // Save user to Firestore
    await _saveUserToFirestore(user);
    
    return user;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = UserModel.fromFirebaseUser(userCredential.user!);
      
      // Save/update user in Firestore
      await _saveUserToFirestore(user);
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    final user = UserModel.fromFirebaseUser(credential.user!);
    
    // Save anonymous user to Firestore
    await _saveUserToFirestore(user);
    
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    
    await user.reload();
    
    // Update in Firestore
    final updatedUser = UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    await _updateUserInFirestore(updatedUser);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');

    // Delete user data from Firestore
    await _firestore.collection('users').doc(user.uid).delete();
    
    // Delete the user account
    await user.delete();
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
      user.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> _updateUserInFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastSignInAt': FieldValue.serverTimestamp(),
    });
  }
}
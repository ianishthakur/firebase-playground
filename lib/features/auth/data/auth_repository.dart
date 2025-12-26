import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_playground/features/auth/data/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });
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

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
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
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();
    final user = UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    await _saveUserToFirestore(user);
    return user;
  }

  Future<void> _ensureInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // authenticate() replaces signIn() in v7+
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Authentication details (idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Authorization details (accessToken) - Required for v7+
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['openid', 'email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = UserModel.fromFirebaseUser(userCredential.user!);

      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    final user = UserModel.fromFirebaseUser(credential.user!);
    await _saveUserToFirestore(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
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
    final updatedUser = UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    await _updateUserInFirestore(updatedUser);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<void> _updateUserInFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastSignInAt': FieldValue.serverTimestamp(),
    });
  }
}

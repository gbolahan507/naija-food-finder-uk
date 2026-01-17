import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

/// Repository for handling authentication operations
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with email and password
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('=== AUTH REPOSITORY: Attempting sign in ===');
      print('Email: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign in successful, user: ${userCredential.user?.email}');

      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      // Update last login time
      try {
        await _updateLastLogin(userCredential.user!.uid);
      } catch (e) {
        print('Warning: Could not update last login: $e');
        // Don't fail login if Firestore update fails
      }

      return await _getUserData(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      print('=== FIREBASE AUTH EXCEPTION (DETAILED) ===');
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');
      print('Email: ${e.email}');
      print('Credential: ${e.credential}');
      print('Phone Number: ${e.phoneNumber}');
      print('Tenant ID: ${e.tenantId}');
      print('Plugin: ${e.plugin}');
      print('Stack Trace: ${e.stackTrace}');
      print('toString(): ${e.toString()}');
      print('==========================================');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('=== UNEXPECTED ERROR (DETAILED) ===');
      print('Error Type: ${e.runtimeType}');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('====================================');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('=== AUTH REPOSITORY: Attempting sign up ===');
      print('Email: $email');
      print('Display Name: $displayName');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign up successful! User: ${userCredential.user?.email}');

      if (userCredential.user == null) {
        throw Exception('Sign up failed');
      }

      // Update display name if provided
      if (displayName != null) {
        print('Updating display name...');
        await userCredential.user!.updateDisplayName(displayName);
        print('Display name updated');
      }

      // Create user document in Firestore
      print('Creating user document in Firestore...');
      await _createUserDocument(
        userCredential.user!,
        displayName: displayName,
      );
      print('User document created successfully');

      print('Fetching user data...');
      final userData = await _getUserData(userCredential.user!);
      print('Sign up complete!');
      return userData;
    } on FirebaseAuthException catch (e) {
      print('=== FIREBASE AUTH EXCEPTION (DETAILED) - SIGNUP ===');
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');
      print('Email: ${e.email}');
      print('Credential: ${e.credential}');
      print('Phone Number: ${e.phoneNumber}');
      print('Tenant ID: ${e.tenantId}');
      print('Plugin: ${e.plugin}');
      print('Stack Trace: ${e.stackTrace}');
      print('toString(): ${e.toString()}');
      print('===================================================');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('=== UNEXPECTED ERROR (DETAILED) - SIGNUP ===');
      print('Error Type: ${e.runtimeType}');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('=============================================');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<AppUser> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }

      // Check if this is a new user
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document for new users
        await _createUserDocument(userCredential.user!);
      } else {
        // Update last login for existing users
        await _updateLastLogin(userCredential.user!.uid);
      }

      return await _getUserData(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign in error: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Get user data from Firestore
  Future<AppUser> _getUserData(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return AppUser.fromFirestore(
      user.uid,
      user.email!,
      doc.data()!,
    );
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    String? displayName,
  }) async {
    final appUser = AppUser(
      id: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      favoriteRestaurants: [],
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(appUser.toFirestore());
  }

  /// Update last login time
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': Timestamp.now(),
    });
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    print('Handling auth exception: ${e.code}');

    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled. Please check Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        // Show the actual error for debugging
        return 'Authentication error [${e.code}]: ${e.message ?? "Unknown error"}';
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No user signed in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }
}

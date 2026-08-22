import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_helper.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _google = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static bool get isLoggedIn => _auth.currentUser != null;

  // ==================== Google Sign-In ====================

  static Future<User?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);

    // Pull data from cloud after login
    if (result.user != null) {
      await DatabaseHelper.instance.pullFromCloud();
    }

    return result.user;
  }

  // ==================== Email/Password Auth ====================

  static Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Send email verification
        await result.user!.sendEmailVerification();

        // Pull data from cloud after signup
        await DatabaseHelper.instance.pullFromCloud();
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  static Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pull data from cloud after login
      if (result.user != null) {
        await DatabaseHelper.instance.pullFromCloud();
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  static Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);
    }
  }

  // ==================== Error Handling ====================

  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // ==================== Sign Out ====================

  static Future<void> signOut() async {
    await Future.wait([
      _google.signOut(),
      _auth.signOut(),
    ]);
  }
}

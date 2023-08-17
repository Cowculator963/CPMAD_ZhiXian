import 'package:firebase_auth/firebase_auth.dart';

// A class that provides authentication methods using Firebase Auth
class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user with email and password
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Registration failed: $e');
      throw e; // Rethrow the exception for handling in UI
    }
  }

  // Sign in an existing user with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in failed: $e');
      throw e; // Rethrow the exception for handling in UI
    }
  }

  // Check if an email already exists for registration
  Future<bool> checkEmailExists(String email) async {
    try {
      // Attempt to create a temporary user with the given email
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'password', // Use a temporary password for checking existence
      );
      // If user creation is successful, it means the email doesn't exist
      // Rollback the user creation by deleting the temporary user
      await userCredential.user?.delete();
      return false;
    } catch (e) {
      // Check the error code to determine if email already exists
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        return true; // Email already exists
      }
      throw e; // Rethrow the exception for handling in UI
    }
  }
}

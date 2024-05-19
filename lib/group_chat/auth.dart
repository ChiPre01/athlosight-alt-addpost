 import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> getInfo() async {
    try {
      // Get the current user from FirebaseAuth
      User? currentUser = _firebaseAuth.currentUser;

      // Return the current user
      return currentUser;
    } catch (e) {
      // Handle any errors that occur during fetching user information
      print('Error fetching user information: $e');
      return null;
    }
  }
}
import 'package:athlosight/policies_with_dialogs/terms_and_privacy.dart';
import 'package:athlosight/screens/home_screen.dart';
import 'package:athlosight/screens/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:athlosight/screens/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();
  bool _showPassword = false;

  void toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> login(String email, String password) async {
    try {
      // Sign in the user with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

 // Set isFirstTimeUser flag to false
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTimeUser', false);

      // Navigate to the home screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const TermsAndPrivacyScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors here
      if (e.code == 'user-not-found') {
        // Handle user not found error
        _logger.i('No user found for that email.');
        showErrorMessage('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // Handle wrong password error
        _logger.i('Wrong password provided.');
        showErrorMessage('Wrong password provided.');
      } else {
        // Handle other errors
        _logger.i('Error occurred: ${e.message}');
        showErrorMessage('An error occurred: ${e.message}');
      }
    } catch (e) {
      _logger.i('Error occurred: $e');
      showErrorMessage('An error occurred: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showSuccessMessage('Password reset email sent. Please check your email.');
    } on FirebaseAuthException catch (e) {
      // Handle password reset errors here
      if (e.code == 'user-not-found') {
        // Handle user not found error
        _logger.i('No user found for that email.');
        showErrorMessage('No user found for that email.');
      } else {
        // Handle other errors
        _logger.i('Error occurred: ${e.message}');
        showErrorMessage('An error occurred: ${e.message}');
      }
    } catch (e) {
      _logger.i('Error occurred: $e');
      showErrorMessage('An error occurred: $e');
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> saveUserData(String email, String uid) async {
    try {
      // Create a Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the user document using the UID
      final DocumentReference userRef = firestore.collection('users').doc(uid);

      // Check if the user document already exists
      final DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        // User document already exists, no need to save again
        _logger.i('User data already exists in Firestore.');
        return;
      }

      // Create a new user document with the email and UID
      await userRef.set({
        'email': email,
        'uid': uid,
      });

      _logger.i('User data saved successfully.');
    } catch (e) {
      _logger.e('Error saving user data: $e');
    }
  }
  
  Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    final String uid = userCredential.user?.uid ?? '';
    

    // Check if the user is signing in for the first time
    final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      // User is already registered, navigate to the home screen
      // Replace 'HomeScreen' with the actual name of your home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      );
    } else {
      // User is signing up for the first time, navigate to the register screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()),
      );
    }
      // Set isFirstTimeUser flag to false
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTimeUser', false);

  } catch (e) {
    _logger.i('Error occurred during Google Sign-In: $e');
    showErrorMessage('$e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
  automaticallyImplyLeading: false, // Remove the default back arrow
  title: Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/IMG-20230529-WA0107.jpg',
          height: 30,
          width: 30,
        ),
      ),
      const SizedBox(width: 8), // Add spacing between the image and title
      Text(
        'Login',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
             ClipRRect(
              borderRadius: BorderRadius.circular(
                  30), // Adjust the radius value as needed
              child: Image.asset(
                'assets/IMG-20230529-WA0107.jpg',
                width: 100,
                height: 100,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: toggleShowPassword,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String email = _emailController.text.trim();
                final String password = _passwordController.text.trim();

                // Call the login method
                login(email, password);
              },
              child: const Text('Login'),
            ),
             const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                final String email = _emailController.text.trim();

                // Call the reset password method
                resetPassword(email);
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
                         const SizedBox(height: 20),
              Stack(
      alignment: Alignment.center,
      children: [
        const Divider(
          color: Colors.deepPurple, // Set the divider color to deep purple
          height: 1,
        ),
        Container(
          color: Colors.white, // Set the background color of the "or" text container
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'or',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.deepPurple, // Set the text color to deep purple
            ),
          ),
        ),
      ],
    ),
                 const SizedBox(height: 5),
        ElevatedButton(
      onPressed: signInWithGoogle, // Call the googleSignIn method when the button is pressed
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/7711fc11b51a844a4e9bd61569e39350.jpg', // Replace this with the path to your Google logo image
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          const Text('Sign in with Google'),
        ],
      ),
        ),
            const SizedBox(
              height: 12,
            ),
          
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text("Don't have an account?"),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
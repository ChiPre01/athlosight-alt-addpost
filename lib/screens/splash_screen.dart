import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package
import 'package:athlosight/screens/welcome_screen.dart'; // Import WelcomeScreen
import 'package:athlosight/screens/home_screen.dart'; // Import HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Make key parameter nullable

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check if the user is already authenticated when the screen initializes
    checkAuthentication();
  }

  void checkAuthentication() async {
    // Get the current user from FirebaseAuth instance
    User? user = FirebaseAuth.instance.currentUser; // Change User to User?

    // Delay for 1 seconds to show splash screen (you can adjust this as needed)
    await Future.delayed(Duration(milliseconds: 1));

    // Navigate to the appropriate screen based on authentication status
    if (user != null) {
      // If user is authenticated, navigate to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
    } else {
      // If user is not authenticated, navigate to WelcomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}

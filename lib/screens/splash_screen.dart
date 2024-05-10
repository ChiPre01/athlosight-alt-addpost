import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:athlosight/screens/welcome_screen.dart';
import 'package:athlosight/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    User? user = FirebaseAuth.instance.currentUser;

    // Delay for 1 second to show splash screen (you can adjust this as needed)
    await Future.delayed(Duration(milliseconds: 1));

    // Check if the widget is still mounted before accessing its context
    if (mounted) {
      // Navigate to the appropriate screen based on authentication status
      if (user != null) {
        // If user is authenticated, navigate to HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        );
      } else {
        // If user is not authenticated, navigate to WelcomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const WelcomeScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}

import 'package:athlosight/firebase_options.dart';
import 'package:athlosight/screens/home_screen.dart';
import 'package:athlosight/screens/welcome_screen.dart';
import 'package:athlosight/themes/theme_provider.dart';
import 'package:athlosight/widgets/initializer_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
 WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase, Mobile Ads, and OneSignal concurrently
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    MobileAds.instance.initialize(),
    SharedPreferences.getInstance(), // Initialize SharedPreferences
  ]);
  OneSignal.initialize("cee3614b-0a84-4f20-a505-7c200ba8a89d");
  // Set OneSignal log level
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Request notification permissions
 OneSignal.Notifications.requestPermission(true);

  // Get SharedPreferences instance
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

  // If it's the first time user, set isFirstTimeUser to false
  if (isFirstTimeUser) {
    prefs.setBool('isFirstTimeUser', false);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Create ThemeProvider instance
      child: InitializerWidget(
        onInitializationComplete: (context) {
          return MyApp(isFirstTimeUser: isFirstTimeUser);
        },
      ),
    ),
  );
}
class MyApp extends StatefulWidget {
  final bool isFirstTimeUser;

  const MyApp({super.key, required this.isFirstTimeUser});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'athlosight',
      home: widget.isFirstTimeUser
          ? WelcomeScreen()
          : HomeScreen(),
    );
  }
}

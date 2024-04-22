import 'package:athlosight/firebase_options.dart';
import 'package:athlosight/notifications/firebase_api.dart';
import 'package:athlosight/notifications/notification_screen.dart';
import 'package:athlosight/screens/login_screen.dart';
import 'package:athlosight/themes/theme_provider.dart';
import 'package:athlosight/widgets/initializer_widget.dart';
import 'package:athlosight/widgets/visible_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseApi().initNotifications();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    print('Error initializing Mobile Ads: $e');
  }

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
          ? LoginScreen()
          : VisibleScreen(initialIndex: 0, userProfileImageUrl: ''),
          navigatorKey: navigatorKey,
          routes: {
            '/notification_screen':(context) => const NotificationScreen(),
          }         
    );
  }
}

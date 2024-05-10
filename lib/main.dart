import 'package:athlosight/firebase_options.dart';
import 'package:athlosight/languages/local_string.dart';
import 'package:athlosight/screens/splash_screen.dart';
import 'package:athlosight/themes/theme_provider.dart';
import 'package:athlosight/widgets/initializer_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Mobile Ads asynchronously
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();

  // Initialize OneSignal asynchronously  
   OneSignal.initialize("cee3614b-0a84-4f20-a505-7c200ba8a89d");
  // Set OneSignal log level
 await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Request notification permissions
  await OneSignal.Notifications.requestPermission(true);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Create ThemeProvider instance
      child: InitializerWidget(
        onInitializationComplete: (context) {
          return const MyApp(); 
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocalString(),
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'athlosight',
      home:  const SplashScreen(),
    );
  }
}

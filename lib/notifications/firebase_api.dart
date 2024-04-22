import 'package:athlosight/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notifications
  Future<void> initNotifications() async {
    //request notification from user(will prompt user)
    await _firebaseMessaging.requestPermission();

    //fetch FCM token for this device
    final FCMToken = await _firebaseMessaging.getToken();

    //print the token(normally you will send this to your server)
    print('Token: $FCMToken');
 
    //initialize further settings for push notifications
    initPushNotifications();
  }

  //function to handle received messages
  void handleMessage(RemoteMessage? message){
    // if the message is null, do nothing
    if(message == null) return;
    //navigate to new screen when message is received, and user taps notification
    navigatorKey.currentState?.pushNamed(
      '/notification_screen', arguments: message,
    );
  }
  //function to initialize background settings
  Future initPushNotifications() async {
    //handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    //attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

     // Listen for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message here
      handleMessage(message);
    });
  }
}
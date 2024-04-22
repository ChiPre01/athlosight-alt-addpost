import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // get the notification message and display on screen
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
       appBar:AppBar(
  backgroundColor: Colors.white, // Set the background color to white
  automaticallyImplyLeading: false, // Remove the default back arrow
  title: Row(
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.deepPurple), // Back icon
        onPressed: () {
          Navigator.pop(context); // Navigate to the previous page
        },
      ),
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
        'Notifications',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
),
body: Column(
  children: [
    Text(message.notification!.title.toString()),
    Text(message.notification!.body.toString()),
    Text(message.data.toString()),
  ],
),
    );
  }
}
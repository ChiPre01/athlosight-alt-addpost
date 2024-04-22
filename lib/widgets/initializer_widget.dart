import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class InitializerWidget extends StatefulWidget {
  final Widget Function(BuildContext) onInitializationComplete;

  const InitializerWidget({
    Key? key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBdURhve8UdtEbk_b_WmNt6RjMpc0fxMnU",
      authDomain: "athlosight3.firebaseapp.com",
      projectId: "athlosight3",
      storageBucket: "athlosight3.appspot.com",
      messagingSenderId: "404846467635",
      appId: "1:404846467635:web:4f3ca8669f02563e83a146",
      measurementId: "G-DRKP1E64TC",
    ),
  );


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.onInitializationComplete(context);
        }
        return CircularProgressIndicator();
      },
    );
  }
}



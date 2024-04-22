import 'package:athlosight/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectThemeScreen extends StatelessWidget {
  const SelectThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
        'Theme',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
), 
body: Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.secondary,
    borderRadius: BorderRadius.circular(12),
  ),
  margin: const EdgeInsets.all(25),
  padding: const EdgeInsets.all(16),
  child: Row(
    children: [
      //dark mode
      Text("Dark Mode"),
      //switch toggle
      CupertinoSwitch(
        value: Provider.of<ThemeProvider>(context, listen: false,).isDarkMode,
        onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false,).toggleTheme(),
      )
    ],
  ),
),
    );
  }
}
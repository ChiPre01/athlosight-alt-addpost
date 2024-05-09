import 'package:athlosight/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:athlosight/policies_with_dialogs/policy_dialog.dart';
import 'package:get/get.dart';

class TermsAndPrivacyScreen extends StatefulWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  TermsAndPrivacyScreenState createState() => TermsAndPrivacyScreenState();
}

class TermsAndPrivacyScreenState extends State<TermsAndPrivacyScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title:  Text('termspolicy'.tr),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child:  Text('clicktoread →'.tr),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return PolicyDialog(mdFileName: 'terms_of_use.md');
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child:  Text(
                      'termsofuse'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('clicktoread →'.tr),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return PolicyDialog(mdFileName: 'privacy_policy.md');
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child:  Text(
                      'privacypolicy'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title:  Text('acceptterms'.tr),
              subtitle: Text('tapterms'.tr),
              value: _termsAccepted,
              onChanged: (bool? value) {
                setState(() {
                  _termsAccepted = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('acceptprivacy'.tr),
              subtitle: Text('tapprivacy'.tr),
              value: _privacyAccepted,
              onChanged: (bool? value) {
                setState(() {
                  _privacyAccepted = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: (_termsAccepted && _privacyAccepted)
                  ? () {
                      // Navigate to the sign-up screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  : null,
              child: Text('continue'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
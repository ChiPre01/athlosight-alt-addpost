import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String? profileImageUrl; // Profile image URL
  final void Function()? onTap;

  const UserTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.profileImageUrl, // Initialize profile image URL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
                    color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 0.25, horizontal: 5),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!) // Load profile image if available
                  : null, // If profile image URL is not available, display nothing
            ),
            const SizedBox(width: 20,),
            // User name
            Text(text), // Displaying username
          ],
        ),
      ),
    );
  }
}
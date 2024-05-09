import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadMessageCount;
  final String profileImageUrl; // Add the profile image URL

  const BottomNavigationBarWidget({
    required this.currentIndex,
    required this.onTap,
    required this.unreadMessageCount,
    required this.profileImageUrl, // Pass the profile image URL
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.deepPurple,
      currentIndex: currentIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: [
       BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.home),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '..',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Posts',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.info),
              // Add badge for decoration
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '..', // You can customize the badge content
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Trials/Camps Setup',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create Content',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search by Username',
        ),
      
        BottomNavigationBarItem(
          icon: CircleAvatar(
            backgroundImage: NetworkImage(profileImageUrl),
            radius: 15, // Adjust the radius as needed
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

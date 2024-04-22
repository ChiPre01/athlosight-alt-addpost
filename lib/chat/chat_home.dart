import 'package:flutter/material.dart';
import 'package:athlosight/chat/chat_service.dart';
import 'package:athlosight/chat/user_tile.dart';
import 'package:athlosight/chat/chat_page.dart'; // Import ChatPage if needed

class ChatHome extends StatelessWidget {
  final String currentUserUid;

  ChatHome({required this.currentUserUid});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: _buildUserList(currentUserUid),
    );
  }

  Widget _buildUserList(String currentUserUid) {
    return StreamBuilder(
  stream: _chatService.getUsersStream(currentUserUid),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Text("Error");
    }
    if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
      return const Text("Loading");
    }
    return ListView(
      children: (snapshot.data as List<Map<String, dynamic>>)
          .map<Widget>((userData) => _buildUserListItem(userData, context))
          .toList(),
    );
  },
);
  }
    Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    final username = userData["username"];
    final profileImageUrl = userData["profileImageUrl"]; // Fetch profile image URL
    if (username != null) {
      return UserTile(
        text: username, // Displaying username instead of email
        profileImageUrl: profileImageUrl, // Pass profile image URL
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUsername: username, // Pass username instead of email
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return SizedBox(); // Or you can display a placeholder widget here
    }
  }
}

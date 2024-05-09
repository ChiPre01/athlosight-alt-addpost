import 'package:flutter/material.dart';
import 'package:athlosight/chat/chat_page.dart';
import 'package:athlosight/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late Stream<List<Map<String, dynamic>>> _chatListStream;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  void _fetchChatList() {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _chatListStream = _chatService.getUsersWithChatroom(currentUserUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chats found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final chat = snapshot.data![index];
                return ListTile(
                  title: Text(chat['username']),
                  subtitle: Text(chat['lastMessage'] ?? 'No messages'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverUsername: chat['username'],
                          receiverID: chat['uid'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'package:athlosight/chat/chat_bubble.dart';
import 'package:athlosight/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUsername;
  final String receiverID;

  ChatPage({
    Key? key,
    required this.receiverUsername,
    required this.receiverID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    //add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        //cause delay so that the keyboard has time to show up
        //then the amount of remaining space will be calculated
        //then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    //wait a bit for listview to be built, then scroll to the bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(
        seconds: 1,
      ),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing current user's ID
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUsername)),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(currentUserID),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(String currentUserID) {
    return StreamBuilder(
      stream: _chatService.getMessages(currentUserID, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }
Widget _buildMessageItem(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  // Extract message details
  String message = data["message"];
  String senderID = data["senderID"];
  Timestamp timestamp = data["timestamp"];

  // Determine if the message sender is the current user
  bool isCurrentUser =
      senderID == FirebaseAuth.instance.currentUser!.uid;
  // Align message to right if sender is the current user, otherwise left
  var alignment =
      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  return Container(
    alignment: alignment,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ChatBubble widget to display the message
        ChatBubble(
          message: message,
          isCurrentUser: isCurrentUser,
        ),
        // Timestamp widget to display the message timestamp
        Text(
          _formatTimestamp(timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}

// Method to format the timestamp into a readable format
String _formatTimestamp(Timestamp timestamp) {
  // Convert timestamp to DateTime object
  DateTime dateTime = timestamp.toDate();
  // Format the DateTime object as desired
  String formattedTime =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return formattedTime;
}


  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: myFocusNode, // Assigning focusNode here
              decoration: InputDecoration(
                hintText: 'Enter your message...',
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
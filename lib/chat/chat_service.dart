import 'package:athlosight/chat/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get user stream
   // Get users with whom the current user shares a chatroom
  Stream<List<Map<String, dynamic>>> getUsersWithChatroom(String currentUserUid) {
    return _firestore
        .collection("chat_rooms")
        .where("members", arrayContains: currentUserUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<String> userIds = [];

      for (final doc in snapshot.docs) {
        final members = doc["members"] as List<dynamic>;
        userIds.addAll(members.cast<String>());
      }

      // Remove duplicates and the current user
      userIds.remove(currentUserUid);
      final uniqueUserIds = userIds.toSet().toList();

      final usersData = await Future.wait(uniqueUserIds.map((userId) async {
        final userDoc = await _firestore.collection("users").doc(userId).get();
        return {
          "uid": userId,
          "username": userDoc["username"],
          "profileImageUrl": userDoc["profileImageUrl"],
        };
      }));

      return usersData;
    });
  }



  //send message
  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //sort the ids (this ensures the chatroomID is the same for any 2 people)
    String chatroomID = ids.join('_');

    //add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //construct chatroomID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
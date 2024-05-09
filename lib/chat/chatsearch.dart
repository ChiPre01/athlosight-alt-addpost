import 'package:athlosight/chat/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatSearch extends StatefulWidget {
  @override
  _ChatSearchState createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Search"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search by username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: onSearch,
                  child: Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: () {
                          chatRoomId(
                              _auth.currentUser!.uid,
                              userMap!['uid']);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverUsername: userMap!['username'],
                                receiverID: userMap!['uid'],
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.account_box, color: Colors.black),
                        title: Text(
                          userMap!['username'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: Icon(Icons.chat, color: Colors.black),
                      )
                    : Container(),
              ],
            ),
    );
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("username", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        if (value.docs.isNotEmpty) {
          userMap = value.docs[0].data() as Map<String, dynamic>;
        } else {
          userMap = null;
        }
        isLoading = false;
      });
      print(userMap);
    });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }
}

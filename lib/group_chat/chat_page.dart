import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final group;
  const ChatPage({Key? key, this.group}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar:AppBar(
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
        'Messages',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StreamBuilder(
              stream: firestore
                  .collection('Chat Rooms')
                  .doc(widget.group)
                  .collection('messages')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return snapshot.hasData
                    ? Expanded(
                        child: ListView.builder(
                            reverse: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, i) {
                              return Row(
                                children: [
                                  if (snapshot.data!.docs.reversed.toList()[i]
                                          ['sender'] ==
                                      auth.currentUser!.email)
                                    const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.indigo,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomRight:
                                                  Radius.circular(10))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: snapshot
                                                      .data!.docs.reversed
                                                      .toList()[i]['sender'] !=
                                                  auth.currentUser!.email
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                snapshot.data!.docs.reversed
                                                    .toList()[i]['sender'],
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 8)),
                                            Text(
                                              snapshot.data!.docs.reversed
                                                  .toList()[i]['msg'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (snapshot.data!.docs.reversed.toList()[i]
                                          ['sender'] !=
                                      auth.currentUser!.email)
                                    const Spacer()
                                ],
                              );
                            }),
                      )
                    : Container();
              }),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(214, 224, 239, 1),
                          borderRadius: BorderRadius.circular(11)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Write Message',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        firestore
                            .collection('Chat Rooms')
                            .doc(widget.group)
                            .collection('messages')
                            .doc(DateTime.now().toString())
                            .set({
                          'sender': auth.currentUser!.email,
                          'msg': controller.text,
                          'time': DateFormat('hh:mm').format(DateTime.now())
                        });
                        controller.clear();
                        setState(() {

                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(214, 224, 239, 1),
                            borderRadius: BorderRadius.circular(11)),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
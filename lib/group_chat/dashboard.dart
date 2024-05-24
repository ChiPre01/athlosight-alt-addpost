import 'package:athlosight/group_chat/auth.dart';
import 'package:athlosight/group_chat/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var data;
  var msgname;
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = 'ca-app-pub-1798341219433190/4386798498'; // replace with your actual ad unit ID

  @override
  void initState() {
    Auth().getInfo().then((value) {
      data = value;
      if (mounted) {
        setState(() {});
      }
    });
        _loadAd();
    super.initState();
  }

  var search = '';

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
        'Group Chats',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
),
floatingActionButton: Container(
  margin: EdgeInsets.only(bottom: 16), // Add margin to create space between the FAB and the bottom of the screen
  child: FloatingActionButton.extended(
    backgroundColor: Colors.white,
    icon: Icon(Icons.add, color: Colors.deepPurple),
    label: Text('Create your Chat Room', style: TextStyle(color: Colors.deepPurple)),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Group Chat Room'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Name',
              ),
              onChanged: (a) {
                setState(() {
                  msgname = a;
                });
              },
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  firestore
                      .collection('Chat Rooms')
                      .doc(msgname)
                      .collection('messages').doc(DateTime.now().toString())
                      .set({
                    'sender': auth.currentUser!.email,
                    'msg': 'Hi! , New Chat Room Created',
                    'time' : DateFormat('hh:mm').format(DateTime.now())
                  });
                  firestore
                      .collection('Chat Rooms')
                      .doc(msgname).set({'status' : 'active'});
                  Navigator.pop(context);
                },
                child: const Text('Create')
              )
            ],
          );
        }
      );
    }
  ),
),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(214, 224, 239, 1),
                  borderRadius: BorderRadius.circular(14)),
              child:  TextField(

                onChanged: (l){
                  setState(() {
                    search = l;
                  });
                },
                decoration: const InputDecoration(
                    hintText: 'Search for Group Chat Room',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Group Chat Rooms',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(18, 38, 67, 1)),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder(
                stream: firestore.collection('Chat Rooms').snapshots(),
                builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : ListView.builder(
                      itemCount: snapshot.data!.docs.where((element){return element.id.contains(search);}).length,
                      itemBuilder: (context, i) {
                          // Insert ad after the first item
                            if (i == 0) {
                              return Column(
                                children: [
                                  GroupCard(
                                      title: snapshot.data!.docs
                                        .where((element) =>
                                            element.id.contains(search))
                                        .toList()[i].id,
                                    snap: snapshot.data!.docs
                                        .where((element) =>
                                            element.id.contains(search))
                                        .toList()[i]
                                        .reference
                                        .collection('messages')
                                        .snapshots(),
                                  ),
                                   if (_nativeAdIsLoaded && _nativeAd != null)
                                    Container(
                                      height: 300,
                                      width: MediaQuery.of(context).size.width,
                                      child: AdWidget(ad: _nativeAd!),
                                    ),
                                ]
                              );
                            }
                          return GroupCard(
                            title: snapshot.data!.docs.where((element){return element.id.contains(search);}).toList()[i].id,
                            snap: snapshot.data!.docs.where((element){return element.id.contains(search);}).toList()[i].reference.collection('messages').snapshots(),
                          );
                        });
                }),
          ))
        ],
      ),
    );
  }
   /// Loads a native ad.
  void _loadAd() {
    setState(() {
      _nativeAdIsLoaded = false;
    });

    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            // ignore: avoid_print
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // ignore: avoid_print
            print('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}

class GroupCard extends StatelessWidget {

  final title;
  final snap;

  const GroupCard({Key? key, this.title, this.snap, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatPage(group: title,);
          }));
        },
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
              color: const Color.fromRGBO(214, 224, 239, 1),
              borderRadius: BorderRadius.circular(11)),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(18, 38, 67, 1),
              ),
              const SizedBox(
                width: 20,
              ),
             Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: const TextStyle(
        color: const Color.fromRGBO(18, 38, 67, 1),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    StreamBuilder(
      stream: snap,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(); // Return an empty container if no data is available
        } else {
          return Text(
            snapshot.data!.docs.last['msg'],
            style: const TextStyle(
              color: Color.fromRGBO(18, 38, 67, 1),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          );
        }
      },
    ),
  ],
),
const Spacer(),
StreamBuilder(
  stream: snap,
  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Container(); // Return an empty container if no data is available
    } else {
      return Text(
        snapshot.data!.docs.last['time'].toString(),
        style: const TextStyle(
          color: const Color.fromRGBO(18, 38, 67, 1),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      );
    }
  },
),
const SizedBox(
  width: 20,
),

            ],
          ),
        ),
      ),
    );
  }
}
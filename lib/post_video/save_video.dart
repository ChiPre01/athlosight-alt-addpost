import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;


class StoreData {
  Future <String> uploadVideo(String videoUrl) async {
    final uid = _auth.currentUser!.uid;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('posts/$uid/$timestamp.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> saveVideoData(String videoDownloadUrl, String caption, String role, String level, String sport, String athleteGender) async {
    final uid = _auth.currentUser!.uid;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('posts').add({
      'uid': uid,
      'videoUrl' : videoDownloadUrl,
      'timestamp': timestamp,
      'caption': caption,
      'role': role,
      'level': level,
      'sport': sport,
      'athletegender': athleteGender,
    });
  }
}
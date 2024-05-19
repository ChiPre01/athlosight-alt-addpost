import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTrialPostScreen extends StatefulWidget {
  const AddTrialPostScreen({Key? key}) : super(key: key);

  @override
  _AddTrialPostScreenState createState() => _AddTrialPostScreenState();
}

class _AddTrialPostScreenState extends State<AddTrialPostScreen> {
  File? _imageFile; // Changed File _imageFile; to File? _imageFile;
  final TextEditingController _captionController = TextEditingController();
  String? _selectedSport;

  final ImagePicker _picker = ImagePicker();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _selectImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _uploadPost() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    if (_selectedSport == null || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please select sport and image'.tr)),
      );
      return;
    }

    final uid = currentUser.uid;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final postRef = _storage.ref().child('posts/$uid/$timestamp.jpg');
      final uploadTask = postRef.putFile(_imageFile!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final caption = _captionController.text.trim();
      await _firestore.collection('posts').add({
        'uid': uid,
        'imageUrl': downloadUrl,
        'timestamp': timestamp,
        'caption': caption,
        'sport': _selectedSport,
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Post uploaded successfully'.tr)),
      );

      // Clear the image file and caption text
      setState(() {
        _imageFile = null;
        _captionController.clear();
        _selectedSport = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $error')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _takePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
            const SizedBox(width: 8),
            Text(
              'Set up trial or camp'.tr,
              style: TextStyle(
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                ),
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Caption or Add your Group Chat Name'.tr,
                ),
              ),
            ),
             SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropdownButton<String>(
               value: _selectedSport, 
               onChanged: (newValue) {
                  setState(() {
                    _selectedSport = newValue;
                  });
                },
                 items:  [
                DropdownMenuItem(
                  value: 'Football/Soccer',
                  child: Text('Football/Soccer'.tr),
                ),
                DropdownMenuItem(
                  value: 'Basketball',
                  child: Text('Basketball'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Tennis',
                  child: Text('Tennis'.tr),
                ),
                DropdownMenuItem(
                  value: 'Rugby',
                  child: Text('Rugby'.tr),
                ),
                DropdownMenuItem(
                  value: 'Cricket',
                  child: Text('Cricket'.tr),
                ),
                DropdownMenuItem(
                  value: 'Volleyball',
                  child: Text('Volleyball'.tr),
                ),
                DropdownMenuItem(
                  value: 'American Football/Gridiron',
                  child: Text('American Football/Gridiron'.tr),
                ),
                DropdownMenuItem(
                  value: 'Futsal',
                  child: Text('Futsal'.tr),
                ),
                DropdownMenuItem(
                  value: 'Athletics',
                  child: Text('Athletics'.tr),
                ),
                DropdownMenuItem(
                  value: 'Mixed Martial Arts',
                  child: Text('Mixed Martial Arts'.tr),
                ),
                DropdownMenuItem(
                  value: 'Boxing',
                  child: Text('Boxing'.tr),
                ),
                DropdownMenuItem(
                  value: 'Baseball',
                  child: Text('Baseball'.tr),
                ),
                DropdownMenuItem(
                  value: 'Field Hockey',
                  child: Text('Field Hockey'.tr),
                ),
                DropdownMenuItem(
                  value: 'Ice Hockey',
                  child: Text('Ice Hockey'.tr),
                ),
                DropdownMenuItem(
                  value: 'Gymnastics',
                  child: Text('Gymnastics'.tr),
                ),
                DropdownMenuItem(
                  value: 'Swimming',
                  child: Text('Swimming'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Wrestling',
                  child: Text('Wrestling'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Kickboxing',
                  child: Text('Kickboxing'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Table Tennis',
                  child: Text('Table Tennis'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Golf',
                  child: Text('Golf'.tr),
                ),
                  DropdownMenuItem(
                  value: 'Snooker',
                  child: Text('Snooker'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Handball',
                  child: Text('Handball'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Beach Soccer',
                  child: Text('Beach Soccer'.tr),
                ),
                 DropdownMenuItem(
                  value: 'Weight Lifting',
                  child: Text('Weight Lifting'.tr),
                ),
              ],
                              hint: Text('Select Sport'.tr),

              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPost,
        child: Icon(Icons.upload),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
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
        const SnackBar(content: Text('Please select sport and image')),
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
        const SnackBar(content: Text('Post uploaded successfully')),
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
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
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
              'Set up trial or camp',
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
                  hintText: 'Caption',
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
                 items: const [
                DropdownMenuItem(
                  value: 'Football/Soccer',
                  child: Text('Football/Soccer'),
                ),
                DropdownMenuItem(
                  value: 'Basketball',
                  child: Text('Basketball'),
                ),
                 DropdownMenuItem(
                  value: 'Tennis',
                  child: Text('Tennis'),
                ),
                DropdownMenuItem(
                  value: 'Rugby',
                  child: Text('Rugby'),
                ),
                DropdownMenuItem(
                  value: 'Cricket',
                  child: Text('Cricket'),
                ),
                DropdownMenuItem(
                  value: 'Volleyball',
                  child: Text('Volleyball'),
                ),
                DropdownMenuItem(
                  value: 'American Football/Gridiron',
                  child: Text('American Football/Gridiron'),
                ),
                DropdownMenuItem(
                  value: 'Futsal',
                  child: Text('Futsal'),
                ),
                DropdownMenuItem(
                  value: 'Athletics',
                  child: Text('Athletics'),
                ),
                DropdownMenuItem(
                  value: 'Mixed Martial Arts',
                  child: Text('Mixed Martial Arts'),
                ),
                DropdownMenuItem(
                  value: 'Boxing',
                  child: Text('Boxing'),
                ),
                DropdownMenuItem(
                  value: 'Baseball',
                  child: Text('Baseball'),
                ),
                DropdownMenuItem(
                  value: 'Field Hockey',
                  child: Text('Field Hockey'),
                ),
                DropdownMenuItem(
                  value: 'Ice Hockey',
                  child: Text('Ice Hockey'),
                ),
                DropdownMenuItem(
                  value: 'Gymnastics',
                  child: Text('Gymnastics'),
                ),
                DropdownMenuItem(
                  value: 'Swimming',
                  child: Text('Swimming'),
                ),
                 DropdownMenuItem(
                  value: 'Wrestling',
                  child: Text('Wrestling'),
                ),
                 DropdownMenuItem(
                  value: 'Kickboxing',
                  child: Text('Kickboxing'),
                ),
                 DropdownMenuItem(
                  value: 'Table Tennis',
                  child: Text('Table Tennis'),
                ),
                 DropdownMenuItem(
                  value: 'Golf',
                  child: Text('Golf'),
                ),
                  DropdownMenuItem(
                  value: 'Snooker',
                  child: Text('Snooker'),
                ),
                 DropdownMenuItem(
                  value: 'Handball',
                  child: Text('Handball'),
                ),
                 DropdownMenuItem(
                  value: 'Beach Soccer',
                  child: Text('Beach Soccer'),
                ),
                 DropdownMenuItem(
                  value: 'Weight Lifting',
                  child: Text('Weight Lifting'),
                ),
              ],
                              hint: Text('Select Sport'),

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

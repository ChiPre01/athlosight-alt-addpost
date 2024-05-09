import 'dart:io';
import 'package:athlosight/screens/full_screen_editprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  final String profileImageUrl;
  final String username;
    final String fullName; // Declare fullName property
    final String currentTeam;
    final String playingCareer;
    final String styleOfPlay;
    final String phoneNumber;
  
  const EditProfileScreen({
    required this.profileImageUrl,
    required this.username,
     required this.fullName,
      required this.currentTeam, 
      required this.playingCareer, 
      required this.styleOfPlay, 
      required this.phoneNumber,               
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedPosition;
  String? _selectedGender;
  String? _currentCountry;

  final List<String> _positions = [
   'Coach/Manager','Goalkeeper(Football/Soccer)', 'Central Defender(Football/Soccer)','Right Wing Back(Football/Soccer)', 'Left Wing Back(Football/Soccer)',
    'Defensive Midfielder(Football/Soccer)','Central Midfielder(Football/Soccer)','Attacking Midfielder(Football/Soccer)', 'Wing Forward(Football/Soccer)'
    'Striker(Football/Soccer)', 'Point Guard(Basketball)', 'Shooting Guard(Basketball)','Center(Basketball)','Small Forward(Basketball)', 'Power Forward(Basketball)',
     'Tennis Player(Tennis)', 'Tight Head Prop(Rugby)','Hooker(Rugby)', 'Loose Head Prop(Rugby)', 'Second Row(Rugby)', 'Blink Side Flanker(Rugby)',
      'Open Side Flanker(Rugby)','Number 8(Rugby)', 'Scrum Half(Rugby)', 'Fly Half(Rugby)', 'Left Wing(Rugby)', 'Inside Center(Rugby)', 'Outside Center(Rugby)',
       'Right Wing(Rugby)','Full Back(Rugby)', 'Wicketkeeper(Cricket)','Slip(Cricket)', 'Gully(Cricket)','Point(Cricket)','Cover(Cricket)', 'Third Man(Cricket)',
        'Fine Leg(Cricket)','Mid Wicket(Cricket)', 'Mid Off(Cricket)', 'Square Leg(Cricket)', 'Captain(Cricket)', 'Outside Hitter(Volleyball)', 'Opposite(Volleyball)',
         'Setter(Volleyball)', 'Middle Blocker(Volleyball)', 'Libero(Volleyball)', 'Defensive Specialist(Volleyball)', 'Serving Specialist(Volleyball)',
          'Center(American Football/Gridiron)', 'Offensive Guard(American Football/Gridiron)', 'Offensive Tackle(American Football/Gridiron)',
           'Quarterback(American Football/Gridiron)', 'Runningback(American Football/Gridiron)','Wide Receiver(American Football/Gridiron)','Tight End(American Football/Gridiron)',
           'Defensive Tackle(American Football/Gridiron)', 'Defensive End(American Football/Gridiron)', 'Linebacker(American Football/Gridiron)',
            'Middle Linebacker(American Football/Gridiron)', 'Outside Linebacker(American Football/Gridiron)', 'Cornerback(American Football/Gridiron)',
             'Safety(American Football/Gridiron)', 'Nickelback and Dimeback(American Football/Gridiron)', 'Kicker(American Football/Gridiron)',
             'Kickoff Specialist(American Football/Gridiron)', 'Punter(American Football/Gridiron)', 'Holder(American Football/Gridiron)','Long Snapper(American Football/Gridiron)',
             'Returner(American Football/Gridiron)','Upback(American Football/Gridiron)','Gunner(American Football/Gridiron)', 'Jammer(American Football/Gridiron)',
             'Goalkeeper(Futsal or Beach Soccer)', 'Defender(Futsal or Beach Soccer)', 'Winger(Futsal or Beach Soccer)', 'Forward(Futsal or Beach Soccer)', '100m Runner(Athletics)',
              '200m Runner(Athletics)', '400m Runner(Athletics)','800m Runner(Athletics)', '1500m Runner(Athletics)','Marathon Runner(Athletics)', 'Relay Runner(Athletics)',
              'Hurdle Runner(Athletics)', 'Long Jump(Athletics)', 'Triple Jump(Athletics)', 'High Jump(Athletics)', 'Pole Vault(Athletics)', 'Shot Put(Athletics)',
             'Discus Throw(Athletics)','Javelin Throw(Athletics)','Mixed Martial Artist(Mixed Martial Arts)','Boxer(Boxing)','Pitcher(Baseball)', 'Catcher(Baseball)',
            'First Baseman(Baseball)', 'Second Baseman(Baseball)','Third Baseman(Baseball)','Shortstop(Baseball)','Left Fielder(Baseball)','Right Fielder(Baseball)',
          'Center Fielder(Baseball)','Middle Infielder(Baseball)','Corner Infielder(Baseball)','Batter(Baseball)','Goalkeeper(Field Hockey)','Defender(Field Hockey)',
           'Sweeper(Field Hockey)','Midfielder(Field Hockey)','Attacker(Field Hockey)','Goalie(Ice Hockey)','Defenseman(Ice Hockey)','Wing(Ice Hockey)','Center(Ice Hockey)',
          'Gymnast(Gymnastics)','Swimmer(Swimming)','Wrestler(Wrestling)', 'Kickboxer(Kickboxing)','Table Tennis Player(Table Tennis)','Golfer(Golf)','Snooker Player(Snooker)',
         'Goalkeeper(Handball)','Left Back(Handball)','Right Back(Handball)','Center Back(Handball)', 'Center Forward(Handball)','Left Winger(Handball)', 'Right Winger(Handball)',
         'Weight Lifter(Weight Lifting)', 'Referee',];
  final List<String> _genders = ['Male','Female',];

  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _fullNameController = TextEditingController();
  late TextEditingController _currentTeamController = TextEditingController();
  late TextEditingController _playingCareerController = TextEditingController();
  late TextEditingController _styleOfPlayController = TextEditingController();
  late TextEditingController _phoneNumberController = TextEditingController();

  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _fullNameController = TextEditingController(text: widget.fullName);
    _currentTeamController = TextEditingController(text: widget.currentTeam);
    _playingCareerController = TextEditingController(text: widget.playingCareer);
    _styleOfPlayController = TextEditingController(text: widget.styleOfPlay);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _currentTeamController.dispose();
    _playingCareerController.dispose();
    _styleOfPlayController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

@override
  void didUpdateWidget(covariant EditProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _usernameController.text = widget.username;
    _fullNameController.text = widget.fullName;
    _currentTeamController.text = widget.currentTeam;
    _playingCareerController.text = widget.playingCareer;
    _styleOfPlayController.text = widget.styleOfPlay;
    _phoneNumberController.text = widget.phoneNumber;
  }

Future<void> _pickProfileImage() async {
  final pickedImage = await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick from Gallery'.tr),
              onTap: () async {
                Navigator.pop(context, await _imagePicker.pickImage(source: ImageSource.gallery));
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take a Photo'.tr),
              onTap: () async {
                Navigator.pop(context, await _imagePicker.pickImage(source: ImageSource.camera));
              },
            ),
          ],
        ),
      );
    },
  );

  if (pickedImage != null) {
    setState(() {
      _profileImage = File(pickedImage.path);
    });
  }
}

Future<void> _updateLocation(String uid) async {
  try {
    // Request location permission
    final PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      print('Location updated successfully');
    } else {
      print('Location permission denied');
    }
  } catch (error) {
    print('Error updating location: $error');
  }
}


  Future<void> _updateCountry() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _currentCountry = placemark.country;
        });

        final String uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'country': _currentCountry,
        });
      }
    } catch (error) {
      print('Error updating country: $error');
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final currentTeam = _currentTeamController.text.trim();
    final playingCareer = _playingCareerController.text.trim();
    final styleOfPlay = _styleOfPlayController.text.trim();
    final playingPosition = _selectedPosition;
    final gender = _selectedGender;
    final phoneNumber = _phoneNumberController.text.trim();

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (_profileImage != null) {
        final String fileName = uid + '_profile_image.jpg';
        final storage.Reference ref = storage.FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
        await ref.putFile(_profileImage!);
        final String imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({'profileImageUrl': imageUrl});
      }

      final userData = {
        'username': username,
        'fullName': fullName,
        'currentTeam': currentTeam,
        'playingCareer': playingCareer,
        'styleOfPlay': styleOfPlay,
        'playingPosition': playingPosition,
        'gender': gender,
        'phoneNumber': phoneNumber,
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update(userData);

      await _updateLocation(uid);
      await _updateCountry();

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Profile saved'.tr)),
      );
    } catch (error) {
      print('Error updating profile data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile')),
      );
    }
  }
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title:  Text('Edit Profile'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
          Stack(
  alignment: Alignment.bottomCenter,
  children: [
   InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(profileImageUrl: widget.profileImageUrl),
      ),
    );
  },
  child: Hero(
    tag: 'profileImage',
   child: CircleAvatar(
    backgroundImage: _profileImage != null
        ? FileImage(_profileImage!) as ImageProvider<Object> // Cast to ImageProvider
        : NetworkImage(widget.profileImageUrl) as ImageProvider<Object>, // Cast to ImageProvider
    radius: 50,
  ),
  ),
),

  
    GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        margin: EdgeInsets.only(left: 80), // Adjust the margin to move the icon to the bottom
        child: Icon(
          Icons.add_a_photo,
          size: 24,
          color: Colors.blue,
        ),
      ),
    ),
  ],
),

            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username'.tr,
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedPosition,
              onChanged: (newValue) {
                setState(() {
                  _selectedPosition = newValue;
                });
              },
              items: _positions.map((position) {
                return DropdownMenuItem<String>(
                  value: position,
                  child: Text(position),
                );
              }).toList(),
              hint: const Text('Select Position'),
              isExpanded: true,
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              items: _genders.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              decoration:  InputDecoration(
                labelText: 'Gender'.tr,
              ),
            ),
            TextField(
              controller: _fullNameController,
              maxLines: null,
              decoration:  InputDecoration(
                labelText: 'Full Name'.tr,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _currentTeamController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Current Team'.tr,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _playingCareerController,
              maxLines: null,
              decoration:  InputDecoration(
                labelText: 'Playing Career'.tr,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _styleOfPlayController,
              maxLines: null,
              decoration:  InputDecoration(
                labelText: 'Style of Play'.tr,
              ),
            ),
             const SizedBox(height: 16.0),
            TextField(
              controller: _phoneNumberController,
              maxLines: null,
              decoration:  InputDecoration(
                labelText: 'Phone Number'.tr,
              ),
            ),
            const SizedBox(height: 32.0),
           ElevatedButton(
  onPressed: () {
    _saveProfile(); // Call _saveProfile directly
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Updated! Changes will be visible when users check your profile'.tr)), // Show a temporary message while processing
    );
  },
  child:  Text('Update Profile'.tr),
),

            if (_currentCountry != null)
              ...[
                const SizedBox(height: 10),
                Text(
                  'Current Country: $_currentCountry',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);
  
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late File _videoFile;
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();
    String? _selectedRole;
  String? _selectedLevel;
  String? _selectedSport;
  String? _selectedAthleteGender;

  final ImagePicker _picker = ImagePicker();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _selectVideoFromGallery() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);

      setState(() {
        _videoFile = videoFile;
        _videoController = VideoPlayerController.file(_videoFile)
          ..initialize().then((_) {
            _videoController!.play();
            _videoController!.setLooping(true);
          });
      });
    }
  }

  Future<void> _recordVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);

      setState(() {
        _videoFile = videoFile;
        _videoController = VideoPlayerController.file(_videoFile)
          ..initialize().then((_) {
            _videoController!.play();
            _videoController!.setLooping(true);
          });
      });
    }
  }

  Future<void> _uploadPost() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    
  if (_selectedRole == null || _selectedLevel == null || _selectedSport == null || _selectedAthleteGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select position, level,sport and gender')),
    );
    return;
  }

    final uid = currentUser.uid;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final postRef =
          _storage.ref().child('posts/$uid/$timestamp.mp4');
      final uploadTask = postRef.putFile(_videoFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final caption = _captionController.text.trim();
      await _firestore.collection('posts').add({
        'uid': uid,
        'videoUrl': downloadUrl,
        'timestamp': timestamp,
        'caption': caption,
        'role': _selectedRole,
      'level': _selectedLevel,
      'sport': _selectedSport,
      'athletegender': _selectedAthleteGender
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully')),
      );

      // Stop video playback and dispose the controller
      _videoController?.pause();
      _videoController?.dispose();

      // Clear the video file, controller, and caption text
      setState(() {
        _videoFile = File('');
        _videoController = null;
        _captionController.clear();
          _selectedRole = null;
      _selectedLevel = null;
      _selectedSport = null;
      _selectedAthleteGender = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $error')),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.white, // Set the background color to white
  automaticallyImplyLeading: false, // Remove the default back arrow
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
      const SizedBox(width: 8), // Add spacing between the image and title
      Text(
        'Add Post',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_videoController != null)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ElevatedButton(
              onPressed: _selectVideoFromGallery,
              child: const Text('Select Video from Gallery'),
            ),
            ElevatedButton(
              onPressed: _recordVideo,
              child: const Text('Record Video'),
            ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropdownButton<String>(
                value: _selectedRole,
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Coach/Manager',
                    child: Text('Coach/Manager'),
                  ),
                  DropdownMenuItem(
                    value: 'Goalkeeper(Football/Soccer)',
                    child: Text('Goalkeeper(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Central Defender(Football/Soccer)',
                    child: Text('Central Defender(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Right Wing Back(Football/Soccer)',
                    child: Text('Right Wing Back(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Left Wing Back(Football/Soccer)',
                    child: Text('Left Wing Back(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Defensive Midfielder(Football/Soccer)',
                    child: Text('Defensive Midfielder(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Central Midfielder(Football/Soccer)',
                    child: Text('Central Midfielder(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Attacking Midfielder(Football/Soccer)',
                    child: Text('Attacking Midfielder(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Wing Forward(Football/Soccer)',
                    child: Text('Wing Forward(Football/Soccer)'),
                  ),
                  DropdownMenuItem(
                    value: 'Striker(Football/Soccer)',
                    child: Text('Striker(Football/Soccer)'),
                  ),
                    DropdownMenuItem(
                    value: 'Point Guard(Basketball)',
                    child: Text('Point Guard(Basketball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Shooting Guard(Basketball)',
                    child: Text('Shooting Guard(Basketball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Center(Basketball)',
                    child: Text('Center(Basketball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Small Forward(Basketball)',
                    child: Text('Small Forward(Basketball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Power Forward(Basketball)',
                    child: Text('Power Forward(Basketball)'),
                  ),
                    DropdownMenuItem(
                    value: 'Tennis Player(Tennis)',
                    child: Text('Tennis Player(Tennis)'),
                  ),
                    DropdownMenuItem(
                    value: 'Tight Head Prop(Rugby)',
                    child: Text('Tight Head Prop(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Hooker(Rugby)',
                    child: Text('Hooker(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Loose Head Prop(Rugby)',
                    child: Text('Loose Head Prop(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Second Row(Rugby)',
                    child: Text('Second Row(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Blink Side Flanker(Rugby)',
                    child: Text('Blink Side Flanker(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Open Side Flanker(Rugby)',
                    child: Text('Open Side Flanker(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Number 8(Rugby)',
                    child: Text('Number 8(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Scrum Half(Rugby)',
                    child: Text('Scrum Half(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Fly Half(Rugby)',
                    child: Text('Fly Half(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Left Wing(Rugby)',
                    child: Text('Left Wing(Rugby)'),
                  ),
                    DropdownMenuItem(
                    value: 'Inside Center(Rugby)',
                    child: Text('Inside Center(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Outside Center(Rugby)',
                    child: Text('Outside Center(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Right Wing(Rugby)',
                    child: Text('Right Wing(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Full Back(Rugby)',
                    child: Text('Full Back(Rugby)'),
                  ),
                   DropdownMenuItem(
                    value: 'Wicketkeeper(Cricket)',
                    child: Text('Wicketkeeper(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Slip(Cricket)',
                    child: Text('Slip(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Gully(Cricket)',
                    child: Text('Gully(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Point(Cricket)',
                    child: Text('Point(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Cover(Cricket)',
                    child: Text('Cover(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Third Man(Cricket)',
                    child: Text('Third Man(Cricket)'),
                  ),  DropdownMenuItem(
                    value: 'Fine Leg(Cricket)',
                    child: Text('Fine Leg(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Mid Wicket(Cricket)',
                    child: Text('Mid Wicket(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Mid Off(Cricket)',
                    child: Text('Mid Off(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Square Leg(Cricket)',
                    child: Text('Square Leg(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Captain(Cricket)',
                    child: Text('Captain(Cricket)'),
                  ),
                    DropdownMenuItem(
                    value: 'Outside Hitter(Volleyball)',
                    child: Text('Outside Hitter(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Opposite(Volleyball)',
                    child: Text('Opposite(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Setter(Volleyball)',
                    child: Text('Setter(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Middle Blocker(Volleyball)',
                    child: Text('Middle Blocker(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Libero(Volleyball)',
                    child: Text('Libero(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Defensive Specialist(Volleyball)',
                    child: Text('Defensive Specialist(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Serving Specialist(Volleyball)',
                    child: Text('Serving Specialist(Volleyball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Center(American Football/Gridiron)',
                    child: Text('Center(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Offensive Guard(American Football/Gridiron)',
                    child: Text('Offensive Guard(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Offensive Tackle(American Football/Gridiron)',
                    child: Text('Offensive Tackle(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Quarterback(American Football/Gridiron)',
                    child: Text('Quarterback(American Football/Gridiron)'),
                  ), 
                   DropdownMenuItem(
                    value: 'Runningback(American Football/Gridiron)',
                    child: Text('Runningback(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Wide Receiver(American Football/Gridiron)',
                    child: Text('Wide Receiver(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Tight End(American Football/Gridiron)',
                    child: Text('Tight End(American Football/Gridiron)'),
                  ),
                    DropdownMenuItem(
                    value: 'Defensive Tackle(American Football/Gridiron)',
                    child: Text('Defensive Tackle(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Defensive End(American Football/Gridiron)',
                    child: Text('Defensive End(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Linebacker(American Football/Gridiron)',
                    child: Text('Linebacker(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Middle Linebacker(American Football/Gridiron)',
                    child: Text('Middle Linebacker(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Outside Linebacker(American Football/Gridiron)',
                    child: Text('Outside Linebacker(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Cornerback(American Football/Gridiron)',
                    child: Text('Cornerback(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Safety(American Football/Gridiron)',
                    child: Text('Safety(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Nickelback and Dimeback(American Football/Gridiron)',
                    child: Text('Nickelback and Dimeback(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Kicker(American Football/Gridiron)',
                    child: Text('Kicker(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Kickoff Specialist(American Football/Gridiron)',
                    child: Text('Kickoff Specialist(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Punter(American Football/Gridiron)',
                    child: Text('Punter(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Holder(American Football/Gridiron)',
                    child: Text('Holder(American Football/Gridiron)'),
                  ), DropdownMenuItem(
                    value: 'Long Snapper(American Football/Gridiron)',
                    child: Text('Long Snapper(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Returner(American Football/Gridiron)',
                    child: Text('Returner(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Upback(American Football/Gridiron)',
                    child: Text('Upback(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Gunner(American Football/Gridiron)',
                    child: Text('Gunner(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Jammer(American Football/Gridiron)',
                    child: Text('Jammer(American Football/Gridiron)'),
                  ),
                   DropdownMenuItem(
                    value: 'Goalkeeper(Futsal or Beach Soccer)',
                    child: Text('Goalkeeper(Futsal or Beach Soccer)'),
                  ),
                   DropdownMenuItem(
                    value: 'Defender(Futsal or Beach Soccer)',
                    child: Text('Defender(Futsal or Beach Soccer)'),
                  ),
                   DropdownMenuItem(
                    value: 'Winger(Futsal or Beach Soccer)',
                    child: Text('Winger(Futsal or Beach Soccer)'),
                  ),
                   DropdownMenuItem(
                    value: 'Forward(Futsal or Beach Soccer)',
                    child: Text('Forward(Futsal or Beach Soccer)'),
                  ),
                   DropdownMenuItem(
                    value: '100m Runner(Athletics)',
                    child: Text('100m Runner(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: '200m Runner(Athletics)',
                    child: Text('200m Runner(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: '400m Runner(Athletics)',
                    child: Text('400m Runner(Athletics)'),
                  ),
                   DropdownMenuItem(
                    value: '800m Runner(Athletics)',
                    child: Text('800m Runner(Athletics)'),
                  ),
                   DropdownMenuItem(
                    value: '1500m Runner(Athletics)',
                    child: Text('1500m Runner(Athletics)'),
                  ),
                   DropdownMenuItem(
                    value: 'Marathon Runner(Athletics)',
                    child: Text('Marathon Runner(Athletics)'),
                  ),
                   DropdownMenuItem(
                    value: 'Relay Runner(Athletics)',
                    child: Text('Relay Runner(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Hurdle Runner(Athletics)',
                    child: Text('Hurdle Runner(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Long Jump(Athletics)',
                    child: Text('Long Jump(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Triple Jump(Athletics)',
                    child: Text('Triple Jump(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'High Jump(Athletics)',
                    child: Text('High Jump(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Pole Vault(Athletics)',
                    child: Text('Pole Vault(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Shot Put(Athletics)',
                    child: Text('Shot Put(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Discus Throw(Athletics)',
                    child: Text('Discus Throw(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Javelin Throw(Athletics)',
                    child: Text('Javelin Throw(Athletics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Mixed Martial Artist(Mixed Martial Arts)',
                    child: Text('Mixed Martial Artist(Mixed Martial Arts)'),
                  ),
                    DropdownMenuItem(
                    value: 'Boxer(Boxing)',
                    child: Text('Boxer(Boxing)'),
                  ),
                   DropdownMenuItem(
                    value: 'Pitcher(Baseball)',
                    child: Text('Pitcher(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Catcher(Baseball)',
                    child: Text('Catcher(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'First Baseman(Baseball)',
                    child: Text('First Baseman(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Second Baseman(Baseball)',
                    child: Text('Second Baseman(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Third Baseman(Baseball)',
                    child: Text('Third Baseman(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Shortstop(Baseball)',
                    child: Text('Shortstop(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Left Fielder(Baseball)',
                    child: Text('Left Fielder(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Right Fielder(Baseball)',
                    child: Text('Right Fielder(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Center Fielder(Baseball)',
                    child: Text('Center Fielder(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Middle Infielder(Baseball)',
                    child: Text('Middle Infielder(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Corner Infielder(Baseball)',
                    child: Text('Corner Infielder(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Batter(Baseball)',
                    child: Text('Batter(Baseball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Goalkeeper(Field Hockey)',
                    child: Text('Goalkeeper(Field Hockey)'),
                  ),
                   DropdownMenuItem(
                    value: 'Defender(Field Hockey)',
                    child: Text('Defender(Field Hockey)'),
                  ),
                   DropdownMenuItem(
                    value: 'Sweeper(Field Hockey)',
                    child: Text('Sweeper(Field Hockey)'),
                  ),
                   DropdownMenuItem(
                    value: 'Midfielder(Field Hockey)',
                    child: Text('Midfielder(Field Hockey)'),
                  ),
                   DropdownMenuItem(
                    value: 'Attacker(Field Hockey)',
                    child: Text('Attacker(Field Hockey)'),
                  ),
                   DropdownMenuItem(
                    value: 'Goalie(Ice Hockey)',
                    child: Text('Goalie(Ice Hockey)'),
                  ),
                    DropdownMenuItem(
                    value: 'Defenseman(Ice Hockey)',
                    child: Text('Defenseman(Ice Hockey)'),
                  ),
                    DropdownMenuItem(
                    value: 'Wing(Ice Hockey)',
                    child: Text('Wing(Ice Hockey)'),
                  ),
                    DropdownMenuItem(
                    value: 'Center(Ice Hockey)',
                    child: Text('Center(Ice Hockey)'),
                  ),
                    DropdownMenuItem(
                    value: 'Gymnast(Gymnastics)',
                    child: Text('Gymnast(Gymnastics)'),
                  ),
                    DropdownMenuItem(
                    value: 'Swimmer(Swimming)',
                    child: Text('Swimmer(Swimming)'),
                  ),
                    DropdownMenuItem(
                    value: 'Wrestler(Wrestling)',
                    child: Text('Wrestler(Wrestling)'),
                  ),
                    DropdownMenuItem(
                    value: 'Kickboxer(Kickboxing)',
                    child: Text('Kickboxer(Kickboxing)'),
                  ),
                    DropdownMenuItem(
                    value: 'Table Tennis Player(Table Tennis)',
                    child: Text('Table Tennis Player(Table Tennis)'),
                  ),
                    DropdownMenuItem(
                    value: 'Golfer(Golf)',
                    child: Text('Golfer(Golf)'),
                  ),
                    DropdownMenuItem(
                    value: 'Snooker Player(Snooker)',
                    child: Text('Snooker Player(Snooker)'),
                  ),
                    DropdownMenuItem(
                    value: 'Goalkeeper(Handball)',
                    child: Text('Goalkeeper(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Left Back(Handball)',
                    child: Text('Left Back(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Right Back(Handball)',
                    child: Text('Right Back(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Center Back(Handball)',
                    child: Text('Center Back(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Center Forward(Handball)',
                    child: Text('Center Forward(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Left Winger(Handball)',
                    child: Text('Left Winger(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Right Winger(Handball)',
                    child: Text('Right Winger(Handball)'),
                  ),
                   DropdownMenuItem(
                    value: 'Weight Lifter(Weight Lifting)',
                    child: Text('Weight Lifter(Weight Lifting)'),
                  ),
                   DropdownMenuItem(
                    value: 'Referee',
                    child: Text('Referee'),
                  ),
                ],
                hint: Text('Select Role'),
              ),
            ),
            DropdownButton<String>(
              value: _selectedLevel,
              onChanged: (newValue) {
                setState(() {
                  _selectedLevel = newValue;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'Top Division Professional',
                  child: Text('Top Division Professional'),
                ),
                DropdownMenuItem(
                  value: 'League Professional/Second Division',
                  child: Text('League Professional/Second Division'),
                ),
                DropdownMenuItem(
                  value: 'League Professional/Third Division',
                  child: Text('League Professional/Third Division'),
                ),
                 DropdownMenuItem(
                  value: 'League Professional/Fourth Division',
                  child: Text('League Professional/Fourth Division'),
                ),
                DropdownMenuItem(
                  value: 'Semi Professional/Fifth and Sixth Division',
                  child: Text('Semi Professional/Fifth and Sixth Division'),
                ),
                DropdownMenuItem(
                  value: 'Semi Professional/Lower Leagues',
                  child: Text('Semi Professional/Lower Leagues'),
                ),
                DropdownMenuItem(
                  value: 'Grassroot/Academy',
                  child: Text('Grassroot/Academy'),
                ),
                 DropdownMenuItem(
                  value: 'Professional(Individual Sports)',
                  child: Text('Professional(Individual Sports)'),
                ),
                 DropdownMenuItem(
                  value: 'Semi Professional(Individual Sports)',
                  child: Text('Semi Professional(Individual Sports)'),
                ),
                 DropdownMenuItem(
                  value: 'Amateur(Individual Sports)',
                  child: Text('Amateur(Individual Sports)'),
                ),
              ],
              hint: Text('Select Level'),
            ),
             DropdownButton<String>(
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
             DropdownButton<String>(
              value: _selectedAthleteGender,
              onChanged: (newValue) {
                setState(() {
                  _selectedAthleteGender = newValue;
                });
              },
               items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                  DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),  
              ],
              hint: Text('Select Athlete Gender'),
            ),
            TextField(
              controller: _captionController,
              maxLines: null, // Allow multiple lines for the caption
              textInputAction: TextInputAction.newline, // Display the enter key for line breaks
              decoration: const InputDecoration(
                hintText: 'Enter caption'                              
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
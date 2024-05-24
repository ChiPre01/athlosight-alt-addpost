import 'dart:io';
import 'package:athlosight/post_video/save_video.dart';
import 'package:athlosight/post_video/video_utilis.dart';
import 'package:athlosight/widgets/visible_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _selectedRole;
  String? _selectedLevel;
  String? _selectedSport;
  String? _selectedAthleteGender;
  String? _videoURL;
  VideoPlayerController? _controller;
  String? _downloadURL; 

  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _pickVideo() async {
    _videoURL = await pickVideo();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videoURL!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

void _uploadVideo() async {
    if (_selectedRole == null ||
        _selectedLevel == null ||
        _selectedSport == null ||
        _selectedAthleteGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select position, level, sport, and gender'.tr)),
      );
      return;
    }

    _downloadURL = await StoreData().uploadVideo(_videoURL!);
    await StoreData().saveVideoData(
      _downloadURL!,
      _captionController.text.trim(),
      _selectedRole!,
      _selectedLevel!,
      _selectedSport!,
      _selectedAthleteGender!,
    );
    setState(() {
      _videoURL = null;
    });
  }


  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          ElevatedButton(onPressed: _uploadVideo, child: const Text('Upload'))
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Set the background color to white
        automaticallyImplyLeading: false, // Remove the default back arrow
        title: Row(
          children: [
            IconButton(
              icon:
                  Icon(Icons.arrow_back, color: Colors.deepPurple), // Back icon
              onPressed: () {
                // Navigate to the home screen and remove all routes on top of it
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisibleScreen(
                      initialIndex: 0,
                      userProfileImageUrl: '',
                    ),
                  ),
                );
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
              'Create Content'.tr,
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
            Center(
              child: _videoURL != null
              ? _videoPreviewWidget()
              : const Text('No Video Selected'),
            ),
            SizedBox(
              height: 20,
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
                items: [
                  DropdownMenuItem(
                    value: 'Coach/Manager',
                    child: Text('Coach/Manager'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Goalkeeper(Football/Soccer)',
                    child: Text('Goalkeeper(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Central Defender(Football/Soccer)',
                    child: Text('Central Defender(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Right Wing Back(Football/Soccer)',
                    child: Text('Right Wing Back(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Left Wing Back(Football/Soccer)',
                    child: Text('Left Wing Back(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defensive Midfielder(Football/Soccer)',
                    child: Text('Defensive Midfielder(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Central Midfielder(Football/Soccer)',
                    child: Text('Central Midfielder(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Attacking Midfielder(Football/Soccer)',
                    child: Text('Attacking Midfielder(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Wing Forward(Football/Soccer)',
                    child: Text('Wing Forward(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Striker(Football/Soccer)',
                    child: Text('Striker(Football/Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Point Guard(Basketball)',
                    child: Text('Point Guard(Basketball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Shooting Guard(Basketball)',
                    child: Text('Shooting Guard(Basketball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center(Basketball)',
                    child: Text('Center(Basketball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Small Forward(Basketball)',
                    child: Text('Small Forward(Basketball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Power Forward(Basketball)',
                    child: Text('Power Forward(Basketball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Tennis Player(Tennis)',
                    child: Text('Tennis Player(Tennis)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Tight Head Prop(Rugby)',
                    child: Text('Tight Head Prop(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Hooker(Rugby)',
                    child: Text('Hooker(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Loose Head Prop(Rugby)',
                    child: Text('Loose Head Prop(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Second Row(Rugby)',
                    child: Text('Second Row(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Blink Side Flanker(Rugby)',
                    child: Text('Blink Side Flanker(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Open Side Flanker(Rugby)',
                    child: Text('Open Side Flanker(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Number 8(Rugby)',
                    child: Text('Number 8(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Scrum Half(Rugby)',
                    child: Text('Scrum Half(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Fly Half(Rugby)',
                    child: Text('Fly Half(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Left Wing(Rugby)',
                    child: Text('Left Wing(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Inside Center(Rugby)',
                    child: Text('Inside Center(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Outside Center(Rugby)',
                    child: Text('Outside Center(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Right Wing(Rugby)',
                    child: Text('Right Wing(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Full Back(Rugby)',
                    child: Text('Full Back(Rugby)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Wicketkeeper(Cricket)',
                    child: Text('Wicketkeeper(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Slip(Cricket)',
                    child: Text('Slip(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Gully(Cricket)',
                    child: Text('Gully(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Point(Cricket)',
                    child: Text('Point(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Cover(Cricket)',
                    child: Text('Cover(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Third Man(Cricket)',
                    child: Text('Third Man(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Fine Leg(Cricket)',
                    child: Text('Fine Leg(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Mid Wicket(Cricket)',
                    child: Text('Mid Wicket(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Mid Off(Cricket)',
                    child: Text('Mid Off(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Square Leg(Cricket)',
                    child: Text('Square Leg(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Captain(Cricket)',
                    child: Text('Captain(Cricket)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Outside Hitter(Volleyball)',
                    child: Text('Outside Hitter(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Opposite(Volleyball)',
                    child: Text('Opposite(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Setter(Volleyball)',
                    child: Text('Setter(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Middle Blocker(Volleyball)',
                    child: Text('Middle Blocker(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Libero(Volleyball)',
                    child: Text('Libero(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defensive Specialist(Volleyball)',
                    child: Text('Defensive Specialist(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Serving Specialist(Volleyball)',
                    child: Text('Serving Specialist(Volleyball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center(American Football/Gridiron)',
                    child: Text('Center(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Offensive Guard(American Football/Gridiron)',
                    child:
                        Text('Offensive Guard(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Offensive Tackle(American Football/Gridiron)',
                    child:
                        Text('Offensive Tackle(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Quarterback(American Football/Gridiron)',
                    child: Text('Quarterback(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Runningback(American Football/Gridiron)',
                    child: Text('Runningback(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Wide Receiver(American Football/Gridiron)',
                    child: Text('Wide Receiver(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Tight End(American Football/Gridiron)',
                    child: Text('Tight End(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defensive Tackle(American Football/Gridiron)',
                    child:
                        Text('Defensive Tackle(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defensive End(American Football/Gridiron)',
                    child: Text('Defensive End(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Linebacker(American Football/Gridiron)',
                    child: Text('Linebacker(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Middle Linebacker(American Football/Gridiron)',
                    child: Text(
                        'Middle Linebacker(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Outside Linebacker(American Football/Gridiron)',
                    child: Text(
                        'Outside Linebacker(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Cornerback(American Football/Gridiron)',
                    child: Text('Cornerback(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Safety(American Football/Gridiron)',
                    child: Text('Safety(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value:
                        'Nickelback and Dimeback(American Football/Gridiron)',
                    child: Text(
                        'Nickelback and Dimeback(American Football/Gridiron)'
                            .tr),
                  ),
                  DropdownMenuItem(
                    value: 'Kicker(American Football/Gridiron)',
                    child: Text('Kicker(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Kickoff Specialist(American Football/Gridiron)',
                    child: Text(
                        'Kickoff Specialist(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Punter(American Football/Gridiron)',
                    child: Text('Punter(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Holder(American Football/Gridiron)',
                    child: Text('Holder(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Long Snapper(American Football/Gridiron)',
                    child: Text('Long Snapper(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Returner(American Football/Gridiron)',
                    child: Text('Returner(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Upback(American Football/Gridiron)',
                    child: Text('Upback(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Gunner(American Football/Gridiron)',
                    child: Text('Gunner(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Jammer(American Football/Gridiron)',
                    child: Text('Jammer(American Football/Gridiron)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Goalkeeper(Futsal or Beach Soccer)',
                    child: Text('Goalkeeper(Futsal or Beach Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defender(Futsal or Beach Soccer)',
                    child: Text('Defender(Futsal or Beach Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Winger(Futsal or Beach Soccer)',
                    child: Text('Winger(Futsal or Beach Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Forward(Futsal or Beach Soccer)',
                    child: Text('Forward(Futsal or Beach Soccer)'.tr),
                  ),
                  DropdownMenuItem(
                    value: '100m Runner(Athletics)',
                    child: Text('100m Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: '200m Runner(Athletics)',
                    child: Text('200m Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: '400m Runner(Athletics)',
                    child: Text('400m Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: '800m Runner(Athletics)',
                    child: Text('800m Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: '1500m Runner(Athletics)',
                    child: Text('1500m Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Marathon Runner(Athletics)',
                    child: Text('Marathon Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Relay Runner(Athletics)',
                    child: Text('Relay Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Hurdle Runner(Athletics)',
                    child: Text('Hurdle Runner(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Long Jump(Athletics)',
                    child: Text('Long Jump(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Triple Jump(Athletics)',
                    child: Text('Triple Jump(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'High Jump(Athletics)',
                    child: Text('High Jump(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Pole Vault(Athletics)',
                    child: Text('Pole Vault(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Shot Put(Athletics)',
                    child: Text('Shot Put(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Discus Throw(Athletics)',
                    child: Text('Discus Throw(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Javelin Throw(Athletics)',
                    child: Text('Javelin Throw(Athletics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Mixed Martial Artist(Mixed Martial Arts)',
                    child: Text('Mixed Martial Artist(Mixed Martial Arts)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Boxer(Boxing)',
                    child: Text('Boxer(Boxing)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Pitcher(Baseball)',
                    child: Text('Pitcher(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Catcher(Baseball)',
                    child: Text('Catcher(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'First Baseman(Baseball)',
                    child: Text('First Baseman(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Second Baseman(Baseball)',
                    child: Text('Second Baseman(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Third Baseman(Baseball)',
                    child: Text('Third Baseman(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Shortstop(Baseball)',
                    child: Text('Shortstop(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Left Fielder(Baseball)',
                    child: Text('Left Fielder(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Right Fielder(Baseball)',
                    child: Text('Right Fielder(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center Fielder(Baseball)',
                    child: Text('Center Fielder(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Middle Infielder(Baseball)',
                    child: Text('Middle Infielder(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Corner Infielder(Baseball)',
                    child: Text('Corner Infielder(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Batter(Baseball)',
                    child: Text('Batter(Baseball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Goalkeeper(Field Hockey)',
                    child: Text('Goalkeeper(Field Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defender(Field Hockey)',
                    child: Text('Defender(Field Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Sweeper(Field Hockey)',
                    child: Text('Sweeper(Field Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Midfielder(Field Hockey)',
                    child: Text('Midfielder(Field Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Attacker(Field Hockey)',
                    child: Text('Attacker(Field Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Goalie(Ice Hockey)',
                    child: Text('Goalie(Ice Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Defenseman(Ice Hockey)',
                    child: Text('Defenseman(Ice Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Wing(Ice Hockey)',
                    child: Text('Wing(Ice Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center(Ice Hockey)',
                    child: Text('Center(Ice Hockey)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Gymnast(Gymnastics)',
                    child: Text('Gymnast(Gymnastics)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Swimmer(Swimming)',
                    child: Text('Swimmer(Swimming)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Wrestler(Wrestling)',
                    child: Text('Wrestler(Wrestling)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Kickboxer(Kickboxing)',
                    child: Text('Kickboxer(Kickboxing)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Table Tennis Player(Table Tennis)',
                    child: Text('Table Tennis Player(Table Tennis)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Golfer(Golf)',
                    child: Text('Golfer(Golf)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Snooker Player(Snooker)',
                    child: Text('Snooker Player(Snooker)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Goalkeeper(Handball)',
                    child: Text('Goalkeeper(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Left Back(Handball)',
                    child: Text('Left Back(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Right Back(Handball)',
                    child: Text('Right Back(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center Back(Handball)',
                    child: Text('Center Back(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Center Forward(Handball)',
                    child: Text('Center Forward(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Left Winger(Handball)',
                    child: Text('Left Winger(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Right Winger(Handball)',
                    child: Text('Right Winger(Handball)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Weight Lifter(Weight Lifting)',
                    child: Text('Weight Lifter(Weight Lifting)'.tr),
                  ),
                  DropdownMenuItem(
                    value: 'Referee',
                    child: Text('Referee'.tr),
                  ),
                ],
                hint: Text('Select Role'.tr),
              ),
            ),
            DropdownButton<String>(
              value: _selectedLevel,
              onChanged: (newValue) {
                setState(() {
                  _selectedLevel = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'Top Division Professional',
                  child: Text('Top Division Professional'.tr),
                ),
                DropdownMenuItem(
                  value: 'League Professional/Second Division',
                  child: Text('League Professional/Second Division'.tr),
                ),
                DropdownMenuItem(
                  value: 'League Professional/Third Division',
                  child: Text('League Professional/Third Division'.tr),
                ),
                DropdownMenuItem(
                  value: 'League Professional/Fourth Division',
                  child: Text('League Professional/Fourth Division'.tr),
                ),
                DropdownMenuItem(
                  value: 'Semi Professional/Fifth and Sixth Division',
                  child: Text('Semi Professional/Fifth and Sixth Division'.tr),
                ),
                DropdownMenuItem(
                  value: 'Semi Professional/Lower Leagues',
                  child: Text('Semi Professional/Lower Leagues'.tr),
                ),
                DropdownMenuItem(
                  value: 'Grassroot/Academy',
                  child: Text('Grassroot/Academy'.tr),
                ),
                DropdownMenuItem(
                  value: 'Professional(Individual Sports)',
                  child: Text('Professional(Individual Sports)'.tr),
                ),
                DropdownMenuItem(
                  value: 'Semi Professional(Individual Sports)',
                  child: Text('Semi Professional(Individual Sports)'.tr),
                ),
                DropdownMenuItem(
                  value: 'Amateur(Individual Sports)',
                  child: Text('Amateur(Individual Sports)'.tr),
                ),
              ],
              hint: Text('Select Level'.tr),
            ),
            DropdownButton<String>(
              value: _selectedSport,
              onChanged: (newValue) {
                setState(() {
                  _selectedSport = newValue;
                });
              },
              items: [
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
            DropdownButton<String>(
              value: _selectedAthleteGender,
              onChanged: (newValue) {
                setState(() {
                  _selectedAthleteGender = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'.tr),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'.tr),
                ),
              ],
              hint: Text('Select Athlete Gender'.tr),
            ),
            TextField(
              controller: _captionController,
              maxLines: null, // Allow multiple lines for the caption
              textInputAction: TextInputAction
                  .newline, // Display the enter key for line breaks
              decoration: InputDecoration(hintText: 'Enter caption'.tr),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: Icon(Icons.upload),
      ),
    );
  }
}

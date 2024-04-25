import 'package:athlosight/screens/edit_profile_screen.dart';
import 'package:athlosight/screens/full_screen_myprofile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:athlosight/screens/comment_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final String userProfileImageUrl;

  MyProfileScreen({required this.userProfileImageUrl});
  

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User? _currentUser;
  DocumentSnapshot? _userData;
  int _followersCount = 0;
  int _followingCount = 0;
  Map<String, ChewieController> chewieControllers = {};
   NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;


 // Add the following line
  final String _adUnitId = 'ca-app-pub-3940256099942544/2247696110'; // replace with your actual ad unit ID
  

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
            _loadAd();
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

  
  Future<void> _getCurrentUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        _currentUser = currentUser;
        _userData = userData;
      });
      _fetchFollowersCount();
      _fetchFollowingCount();
    }
  }

  Future<void> _fetchFollowersCount() async {
    final followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('followers')
        .get();
    setState(() {
      _followersCount = followersSnapshot.size;
    });
  }

  Future<void> _fetchFollowingCount() async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('following')
        .get();
    setState(() {
      _followingCount = followingSnapshot.size;
    });
  }

  ChewieController getChewieController(String videoUrl) {
    if (!chewieControllers.containsKey(videoUrl) ||
        chewieControllers[videoUrl] == null) {
      final videoPlayerController = VideoPlayerController.network(videoUrl);
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        autoInitialize: true,
      );

      chewieControllers[videoUrl] = chewieController;
    }
    return chewieControllers[videoUrl]!;
  }

  @override
  void dispose() {
                _nativeAd?.dispose(); // Dispose of the native ad
    final List<ChewieController> controllerValues =
        chewieControllers.values.toList();
    for (final controller in controllerValues) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Step 1: Delete the post
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // Step 2: Delete associated data like likes and comments
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Display a success message or perform any other necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      // Handle any errors that may occur during the deletion process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  Future<void> _toggleLike(String postId, bool isLiked) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Update the like count and isLiked for the post
      await postRef.update({
        'likesCount':
            isLiked ? FieldValue.increment(-1) : FieldValue.increment(1),
        'isLiked': !isLiked,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _userData == null) {
      // Display a loading indicator while data is being fetched
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userData = _userData!.data() as Map<String, dynamic>?;
    final profileImageUrl = userData?['profileImageUrl'] as String?;
    final username = userData?['username'] as String?;
    final country = userData?['country'] as String?;
    final age = userData?['age'] as int?;
    final fullName = userData?['fullName'] as String?;
    final playingPosition = userData?['playingPosition'] as String?;
    final gender = userData?['gender'] as String?;
    final currentTeam = userData?['currentTeam'] as String?;
    final playingCareer = userData?['playingCareer'] as String?;
    final styleOfPlay = userData?['styleOfPlay'] as String?;
    final phoneNumber = userData?['phoneNumber'] as String?;

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
              username ?? '',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageProfile(
                        imageUrl: profileImageUrl ?? '',
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Hero(
                    tag: 'fullscreen-image',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl ?? ''),
                      radius: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Full Name: ${fullName ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Country: ${country ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Age: ${age?.toString() ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Playing Position: ${playingPosition ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Gender: ${gender ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Current Team: ${currentTeam ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Playing Career: ${playingCareer ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Style of Play: ${styleOfPlay ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
               Text(
                'Phone Number: ${phoneNumber ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
             ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          profileImageUrl: profileImageUrl ?? '', // Default value is an empty string
          username: username ?? '', // Default value is an empty string
          fullName: fullName ?? '', // Default value is an empty string
          currentTeam: currentTeam ?? '', // Default value is an empty string
          playingCareer: playingCareer ?? '', // Default value is an empty string
          styleOfPlay: styleOfPlay ?? '', // Default value is an empty string
          phoneNumber: phoneNumber ?? '',
        ),
      ),
    );
  },
                  child: const Text('Edit Profile'),

),

              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Fanbase: $_followersCount',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Fanning: $_followingCount',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Posts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: _currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final posts = snapshot.data!.docs;

                 return ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: posts.length,
  itemBuilder: (context, index) {
    final post = posts[index].data() as Map<String, dynamic>;
    final caption = post['caption'] as String? ?? '';
    final videoUrl = post['videoUrl'] as String? ?? '';
    final timestampStr = post['timestamp'] as String;
    final timestampMillis = int.tryParse(timestampStr) ?? 0;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    final formattedTimestamp =
        DateFormat.yMMMMd().add_jm().format(timestamp);
    final isLiked = post['isLiked'] ?? false;
    final likesCount = post['likesCount'] ?? 0;

    // Build the post widget
    Widget postWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(
            controller: getChewieController(videoUrl),
          ),
        ),
        ListTile(
          title: Text(caption),
          subtitle: Text(formattedTimestamp),
          onTap: () {
            // Handle post tap
            // You can navigate to a detailed post screen or perform any action you want
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Handle like functionality
                    _toggleLike(posts[index].id, isLiked);
                  },
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.deepPurpleAccent : null,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$likesCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text(
                      'Likes',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          postId: posts[index].id,
                          currentUsername: username!,
                          profileImageUrl: profileImageUrl!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.comment),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(posts[index].id)
                      .collection('comments')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                            ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return const SizedBox();
                    }

                    final commentsCount = snapshot.data!.docs.length;

                    return Text('$commentsCount');
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    final String textToShare =
                        'Check out this post: $caption\n\nVideo: $videoUrl';

                    // Share the post using the flutter_share package
                    await FlutterShare.share(
                      title: 'Shared Post',
                      text: textToShare,
                      chooserTitle: 'Share',
                    );
                  },
                  icon: const Icon(Icons.share),
                ),
                const Text('Share'),
              ],
            ),
            IconButton(
              onPressed: () => _deletePost(posts[index].id),
              icon: Icon(Icons.delete_rounded),
            ),
          ],
        ),
      ],
    );

    if (index == 0 && _nativeAdIsLoaded && _nativeAd != null) {
      // If it's the first post, insert the native ad
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          postWidget, // Post widget
          SizedBox(
            height: 300, // Adjust the height as needed
            width: MediaQuery.of(context).size.width,
            child: AdWidget(ad: _nativeAd!), // Native ad widget
          ),
        ],
      );
    } else {
      // Otherwise, just return the post widget
      return postWidget;
    }
  },
);


                  }
                  return const SizedBox(); // Return an empty container if no data
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

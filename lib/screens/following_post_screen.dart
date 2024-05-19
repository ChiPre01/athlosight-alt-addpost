import 'package:athlosight/group_chat/dashboard.dart';
import 'package:athlosight/screens/add_trial_post_screen.dart';
import 'package:athlosight/screens/login_screen.dart';
import 'package:athlosight/widgets/visible_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:chewie/chewie.dart';
import 'package:athlosight/screens/comment_screen.dart';
import 'package:athlosight/screens/my_profile_screen.dart';
import 'package:athlosight/screens/user_profile_screen.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
       backgroundColor: Colors.deepPurple,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.home),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '..',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Posts'.tr,
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.info),
              // Add badge for decoration
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '..', // You can customize the badge content
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Trials/Camps Setup'.tr,
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create Content'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search by Username'.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'My Profile'.tr,
        ),
      ],
    );
  }
}

class FollowingPostScreen extends StatefulWidget {
  const FollowingPostScreen({Key? key}) : super(key: key);

  @override
  State<FollowingPostScreen> createState() => _FollowingPostScreenState();
}

class User {
  final String profileImageUrl;
  final String username;
  final String country;
  final String age;
  final String userId;

  User({
    required this.profileImageUrl,
    required this.username,
    required this.country,
    required this.age,
    required this.userId,
  });
}

class _FollowingPostScreenState extends State<FollowingPostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  Map<String, ChewieController> chewieControllers = {};
  final logger = Logger();
  final Set<String> deletedPostIds = {};
  List<User> usersList = [];
  String? currentUserId;
  String? filterAge;
  String? filterSport;
  String? filterCountry;
  String? filterLevel;
  String? filterRole;
    String? filterAthleteGender;
     NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;


 // Add the following line
  final String _adUnitId = 'ca-app-pub-1798341219433190/4386798498'; // replace with your actual ad unit ID

  List<String> followingUserIds = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchUserData();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
            _loadAd(); // Load the native ad
  }

  Future<void> _fetchUserData() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      usersList = usersSnapshot.docs.map((userDoc) {
        final userData = userDoc.data();
        return User(
          profileImageUrl: userData['profileImageUrl'] ?? '',
          username: userData['username'] ?? '',
          country: userData['country'] ?? '',
          age: userData['age']?.toString() ?? '',
          userId: userDoc.id,
        );
      }).toList();
    } catch (e) {
      print('Error fetching user data: $e');
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final followingSnapshot = await _firestore.collection('users').doc(currentUser.uid).collection('following').get();
        followingUserIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      }

      final postsSnapshot = await _firestore.collection('posts').where('uid', whereIn: followingUserIds).get();
      final posts = postsSnapshot.docs;
      print('Fetched ${posts.length} posts');
    } catch (e) {
      print('Error fetching posts data: $e');
    }

    setState(() {});
  }

  @override
  void dispose() {
            _nativeAd?.dispose(); // Dispose of the native ad
    final List<ChewieController> controllerValues = chewieControllers.values.toList();
    for (final controller in controllerValues) {
      controller.dispose();
    }
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }
    // Add the signOut method
Future<void> _signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    print('User signed out successfully');
    // Navigate to the SignUpScreen after signing out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(), // Replace SignUpScreen with your actual sign-up screen widget
      ),
    );
  } catch (e) {
    print('Error signing out: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Row(
          children: [
             IconButton(
  icon: Icon(Icons.arrow_back, color: Colors.deepPurple), // Back icon
  onPressed: () {
    // Navigate to the home screen and remove all routes on top of it
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VisibleScreen(initialIndex: 0, userProfileImageUrl: '',),
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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final selectedOption = await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(0, 56, 0, 0), // Adjust the position as needed
                  items: [
                    PopupMenuItem<String>(
                      value: 'posts',
                      child: Row(
                        children: [
                          Icon(Icons.home, color: Colors.deepPurple,), // Home icon
                          const SizedBox(width: 8),
                          Text('Posts'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'fanning',
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.deepPurple,), // Favorite icon
                          const SizedBox(width: 8),
                          Text('Fanning'.tr),
                        ],
                      ),
                    ),
                   
                  ],
                );

                if (selectedOption == 'posts') {
                  // Handle the 'posts' option click
                  // You can navigate to the posts page or perform any desired action
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisibleScreen(initialIndex: 0, userProfileImageUrl: 'userProfileImageUrl',),
                    ),
                  );
                } else if (selectedOption == 'fanning') {
                  // Handle the 'fanning' option click
                  // You can navigate to the fanning page or perform any desired action
                                                      _fetchUserData();
                }
              },
              child: const Text(
                '♥ ▼',
                style: TextStyle(color: Colors.deepPurple,),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
         actions: [
        
  
  PopupMenuButton<String>(
  onSelected: (value) async {
    // Handle the selected option
    if (value == 'sign out') {
      // Handle logout option
      await _signOut();
    } else if (value == 'group_chats') {
          // Handle Group Chats option
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Dashboard(),
            ),
          );
        } else if (value == 'trial_setup') {
          // Handle Trial Setup option
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTrialPostScreen(),
            ),
          );
        }
  },

  itemBuilder: (context) => [
     PopupMenuItem<String>(
          value: 'group_chats',
          child: Row(
            children: [
              const Icon(
                Icons.mail,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text('Group Chats'.tr),
            ],
          ),
        ),
         PopupMenuItem<String>(
          value: 'trial_setup',
          child: Row(
            children: [
              const Icon(
                Icons.add,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text('Trial Setup'.tr),
            ],
          ),
        ),
    PopupMenuItem<String>(
      value: 'sign out',
      child: Row(
        children: [
          Icon(
            Icons.logout,
            color: Colors.deepPurple,
          ),
          const SizedBox(width: 8),
          Text('Sign Out'.tr),
        ],
      ),
    ),
  ],
  icon: Icon(Icons.more_vert, color: Colors.deepPurple),
),

  ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildAgeFilterDropdown(),
                buildSportFilterDropdown(),
                buildLevelFilterDropdown(),
                buildCountryFilterDropdown(),
                buildRoleFilterDropdown(),
                buildAthleteGenderFilterDropdown(),

              ],
            ),
          ),
          Expanded(
            child: usersList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : followingUserIds.isEmpty
                    ? Center(child: Text('You are not following any user.'.tr))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('posts').where('uid', whereIn: followingUserIds).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final posts = snapshot.data!.docs;

                          final filteredPosts = posts.where((post) {
                            final postData = post.data() as Map<String, dynamic>;
                            final user = usersList.firstWhere(
                              (user) => user.userId == postData['uid'],
                              orElse: () => User(
                                profileImageUrl: '',
                                username: 'Unknown',
                                country: 'Unknown',
                                age: '',
                                userId: postData['uid'],
                              ),
                            );

                            
                      if (filterAge != null && filterAge != 'Default') {
  final ageRange = filterAge!.split(' - ');
  if (ageRange.length == 2) {
    final ageLowerLimit = int.tryParse(ageRange[0]);
    final ageUpperLimit = int.tryParse(ageRange[1]);
    if (ageLowerLimit != null && ageUpperLimit != null) {
      final userAge = int.parse(user.age);
      if (userAge >= ageLowerLimit && userAge <= ageUpperLimit) {
        return true;
      }
    }
  } else if (ageRange.length == 3) {
    final ageLowerLimit = int.tryParse(ageRange[0]);
    if (ageLowerLimit != null) {
      final userAge = int.parse(user.age);
      if (userAge >= ageLowerLimit) {
        return true;
      }
    }
  }
  return false;
}
                                     return (postData['videoUrl'] != null) && // Ensure there's a video URL
                            (filterAge == null || user.age == filterAge) &&
                                (filterLevel == null || postData['level'] == filterLevel) &&
                                (filterSport == null || postData['sport'] == filterSport) &&
                                (filterCountry == null || user.country == filterCountry) &&
                                (filterRole == null || postData['role'] == filterRole) &&
                                (filterAthleteGender == null || postData['athletegender'] == filterAthleteGender); 

                          }).toList();

return ListView.builder(
  controller: _scrollController,
  itemCount: filteredPosts.length + ((filteredPosts.length ~/ 3) + 1),
  itemBuilder: (context, index) {
    if (index != 0 && index % 4 == 0 && _nativeAdIsLoaded) {
      // Index is a multiple of 6 (after the first item), return an ad widget
      return Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      // Calculate the adjusted post index for non-ad items
      final adjustedPostIndex = index - ((index ~/ 4) + 1);
      if (adjustedPostIndex >= 0 && adjustedPostIndex < filteredPosts.length) {
        // Return a post widget
        final postIndex = adjustedPostIndex;
        final post = filteredPosts[postIndex].data() as Map<String, dynamic>;
        final postId = filteredPosts[postIndex].id;

        if (deletedPostIds.contains(postId)) {
          return SizedBox();
        }

        final user = usersList.firstWhere(
          (user) => user.userId == post['uid'],
          orElse: () => User(
            profileImageUrl: '',
            username: 'Unknown',
            country: 'Unknown',
            age: '',
            userId: post['uid'],
          ),
        );

        final level = post['level'] ?? '';
        final role = post['role'] ?? '';
        final sport = post['sport'] ?? '';
        final caption = post['caption'] ?? '';
        final videoUrl = post['videoUrl'] ?? '';
        final timestampStr = post['timestamp'] as String;
        final athletegender = post['athletegender'] ?? '';

        final chewieController = getChewieController(videoUrl);

        final timestampMillis = int.tryParse(timestampStr) ?? 0;
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis);
        final formattedTimestamp =
            DateFormat.yMMMMd().add_jm().format(timestamp);

        final isLikedByCurrentUser = post['likes'] != null &&
            post['likes'][currentUserId] == true;

        return Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                title: Text(user.username),
                onTap: () {
                  if (user.userId ==
                      FirebaseAuth.instance.currentUser?.uid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyProfileScreen(userProfileImageUrl: ''),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId: user.userId,
                        ),
                      ),
                    );
                  }
                },
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                          '${user.country}, $athletegender, ${user.age}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('Sport: $sport',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('Role: $role',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('Level: $level',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Text(formattedTimestamp),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(caption),
              ),
              AspectRatio(
                aspectRatio: 10 / 16,
                child: Chewie(
                  controller: chewieController,
                ),
              ),
              Builder(
                builder: (context) {
                  final likesCount = post['likesCount'] ?? 0;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _toggleLike(postId, isLikedByCurrentUser);
                            },
                            icon: Icon(
                              isLikedByCurrentUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLikedByCurrentUser
                                  ? Colors.deepPurpleAccent
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                    postId: postId,
                                    currentUsername: user.username,
                                    profileImageUrl: user.profileImageUrl,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.comment),
                          ),
                          IconButton(
                            onPressed: () async {
                              final String textToShare =
                                  'Check out this post: $caption\n\nVideo: $videoUrl';

                              await FlutterShare.share(
                                title: 'Shared Post',
                                text: textToShare,
                                chooserTitle: 'Share',
                              );
                            },
                            icon: const Icon(Icons.share),
                          ),
                          IconButton(
                            onPressed: () {
                              if (!deletedPostIds.contains(postId)) {
                                _deletePost(postId, context);
                              }
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$likesCount',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                               Text(
                                'Likes'.tr,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          FutureBuilder<QuerySnapshot>(
                            future: _firestore
                                .collection('posts')
                                .doc(postId)
                                .collection('comments')
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return const SizedBox();
                              }

                              final commentsCount =
                                  snapshot.data!.docs.length;

                              return Row(
                                children: [
                                  Text(
                                    '$commentsCount',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                   Text(
                                    'Comments'.tr,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      } else {
        return SizedBox();
      }
    }
  },
);


                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Perform operations based on the selected index
          switch (index) {
            case 0:
              // Navigate to PostScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisibleScreen(initialIndex: 0, userProfileImageUrl: '',),
                ),
              );
              break;
               case 1:
              // Navigate to TrialInfoScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisibleScreen(initialIndex: 1, userProfileImageUrl: '',),
                ),
              );
              break;
            case 2:
              // Navigate to AddPostScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisibleScreen(initialIndex: 2, userProfileImageUrl: '',),
                ),
              );
              break;
            case 3:
              // Navigate to SearchScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                                    builder: (context) => VisibleScreen(initialIndex: 3, userProfileImageUrl: '',),

                ),
              );
              break;
           
            case 4:
              // Navigate to MyProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                                    builder: (context) => VisibleScreen(initialIndex: 4, userProfileImageUrl: '',),

                ),
              );
              break;
          }
        },
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

  ChewieController getChewieController(String videoUrl) {
    if (!chewieControllers.containsKey(videoUrl) || chewieControllers[videoUrl] == null) {
      final videoPlayerController = VideoPlayerController.network(videoUrl);
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 10 / 16,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        autoInitialize: true,
      );

      chewieController.videoPlayerController.addListener(() {
        if (chewieController.videoPlayerController.value.isPlaying) {
          print('Video started playing');
        }
      });

      chewieControllers[videoUrl] = chewieController;
    }
    return chewieControllers[videoUrl]!;
  }

  
  List<String> ageRanges = [
    '7 - 9',
    '10 - 13',
    '14 - 17',
    '18 - 20',
    '21 - 23',
    '24 - 27',
    '28 - 30',
    '31 - 32',
    '33 - 35',
    '36 - 39',
    '40 - 45',
    '46 - 50',
    '51 and above',
  ]; // Add your desired age range options here

  Widget buildAgeFilterDropdown() {
    return DropdownButton<String>(
      value: filterAge,
      onChanged: (String? newValue) {
        setState(() {
          filterAge = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...ageRanges.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Age Range'.tr),
    );
  }

  // Repeat the same pattern for other filter dropdowns

  Widget buildSportFilterDropdown() {
     final sports = ['Football/Soccer'.tr, 'Basketball'.tr, 'Tennis'.tr, 'Rugby'.tr, 'Cricket'.tr, 'Volleyball'.tr, 'American Football/Gridiron'.tr, 'Futsal/7 or 5 a side'.tr,
    'Athletics'.tr, 'Mixed Martial Arts'.tr,'Boxing'.tr, 'Baseball'.tr, 'Field Hockey'.tr,'Ice Hockey'.tr, 'Gymnastics'.tr, 'Swimming'.tr, 'Wrestling'.tr, 'Kickboxing'.tr, 
    'Table Tennis'.tr,'Golf'.tr,'Snooker'.tr, 'Handball'.tr,'Weight Lifting'.tr];
    return DropdownButton<String>(
      value: filterSport,
      onChanged: (String? newValue) {
        setState(() {
          filterSport = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...sports.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Sport'),
    );
  }

  // Repeat the same pattern for other filter dropdowns

  Widget buildCountryFilterDropdown() {
    final countries = ['Afghanistan','Albania','Algeria','American Samoa','Andorra','Angola','Anguilla','Antigua and Barbuda','Argentina',
    'Armenia','Aruba','Australia','Austria','Azerbaijan','Bahamas','Bahrain','Bangladesh','Barbados','Belarus','Belgium','Belize','Benin','Bermuda',
    'Bhutan','Bolivia','Bosnia and Herzegovina','Botswana','Brazil','Brunei Darussalam','Bulgaria','Burkina Faso','Burundi','Cambodia','Cameroon','Canada',
    'Cape Verde','Cayman Islands','Central African Republic','Chad','Chile','China','Christmas Island','Cocos Islands','Colombia','Comoros',
    'Democratic Republic of Congo','Republic of Congo','Cook Islands','Costa Rica','Croatia','Cuba','Cyprus','Czech Republic','Denmark','Djibouti',
    'Dominica','Dominican Republic','East Timor','Ecuador','Egypt','El Salvador','Equatorial Guinea','Eritrea','Estonia','Ethiopia','Falkland Islands',
    'Faroe Islands','Fiji','Finland','France','French Guiana','French Polynesia','French Southern Territories','Gabon','Gambia','Georgia','Germany','Ghana',
    'Gibraltar','Greece','Greenland','Grenada','Guadeloupe','Guam','Guatemala','Guinea','Guinea-Bissau','Guyana','Haiti','Holy See','Honduras','Hong Kong',
    'Hungary','Iceland','India','Indonesia','Iran','Iraq','Ireland','Israel','Italy','Ivory Coast','Jamaica','Japan','Jordan','Kazakhstan','Kenya',
    'Kiribati','North Korea','South Korea','Kosovo','Kuwait','Kyrgyzstan','Lao','Latvia','Lebanon','Lesotho','Liberia','Libya','Liechtenstein','Lithuania','Luxembourg',
    'Macau','Madagascar','Malawi','Malaysia','Maldives','Mali','Malta','Marshall Islands','Martinique','Mauritania','Mauritus','Mayotte','Mexico','Micronesia',
    'Moldova','Monaco','Mongolia','Montenegro','Montserrat','Morrocco','Mozambique','Myanmar','Namibia','Nauru','Nepal','Netherlands',
    'Netherlands Antilles','New Caledonia','New Zealand','Nicaragua','Niger','Nigeria','Niue','North Macedonia','Northern Mariana Islands','Norway','Oman'
    'Pakistan','Palau','Palestine','Panama','Papua New Guinea','Paraguay','Peru','Philippines','Pitcairn Island','Poland','Portugal','Puerto Rico','Qatar'
    'Reunion Island','Romania','Russia','Rwanda','Saint Kitts and Nevis','Saint Lucia','Saint Vincent and the Grenadines','Samoa','San Marino',
    'Sao Tome and Principe','Saudi Arabia','Senegal','Serbia','Seychelles','Sierra Leone','Singapore','Slovakia','Slovenia','Solomon Islands','Somalia',
    'South Africa','South Sudan','Spain','Sri Lanka','Sudan','Suriname','Swaziland','Syria','Taiwan','Tajikistan','Tanzania','Thailand','Tibet','Timor-Leste',
    'Togo','Tokelau','Tonga','Trinidad and Tobago','Tunisia','Turkey','Turkmenistan','Turks and Caicos Islands','Tuvalu','Uganda','Ukraine',
    'United Arab Emirates','United Kingdom','United States','Uruguay','Uzbekistan','Vanautu','Vatican City State','Venezuela','Vietnam',
    'Virgin Islands','Wallis and Futuna Islands','Western Sahara','Yemen','Zambia','Zimbabwe'];
    return DropdownButton<String>(
      value: filterCountry,
      onChanged: (String? newValue) {
        setState(() {
          filterCountry = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...countries.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Regions'.tr),
    );
  }

  // Repeat the same pattern for other filter dropdowns

  Widget buildLevelFilterDropdown() {
      final levels = [ 'Top Division Professional'.tr, 'League Professional/Second Division'.tr, 'League Professional/Third Division'.tr, 'League Professional/Fourth Division'.tr,
     'Semi Professional/Fifth and Sixth Division'.tr, 'Semi Professional/Lower Leagues'.tr, 'Grassroot/Academy'.tr,'Professional(Individual Sports)'.tr,
      'Semi Professional(Individual Sports)'.tr, 'Amateur(Individual Sports)'.tr];
    return DropdownButton<String>(
      value: filterLevel,
      onChanged: (String? newValue) {
        setState(() {
          filterLevel = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...levels.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Level'.tr),
    );
  }

    Widget buildAthleteGenderFilterDropdown() {
    final athletegenders = [ 'Male'.tr,'Female'.tr,];
    return DropdownButton<String>(
      value: filterAthleteGender,
      onChanged: (String? newValue) {
        setState(() {
          filterAthleteGender = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...athletegenders.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Athlete Gender'.tr),
    );
  }
   // Repeat the same pattern for other filter dropdowns

  Widget buildRoleFilterDropdown() {
      final roles = ['Coach/Manager'.tr,'Goalkeeper(Football/Soccer)'.tr, 'Central Defender(Football/Soccer)'.tr,'Right Wing Back(Football/Soccer)'.tr, 'Left Wing Back(Football/Soccer)'.tr,
    'Defensive Midfielder(Football/Soccer)'.tr,'Central Midfielder(Football/Soccer)'.tr,'Attacking Midfielder(Football/Soccer)'.tr, 'Wing Forward(Football/Soccer)'.tr,
    'Striker(Football/Soccer)'.tr, 'Point Guard(Basketball)'.tr, 'Shooting Guard(Basketball)'.tr,'Center(Basketball)'.tr,'Small Forward(Basketball)'.tr, 'Power Forward(Basketball)'.tr,
     'Tennis Player(Tennis)'.tr, 'Tight Head Prop(Rugby)'.tr,'Hooker(Rugby)'.tr, 'Loose Head Prop(Rugby)'.tr, 'Second Row(Rugby)'.tr, 'Blink Side Flanker(Rugby)'.tr,
      'Open Side Flanker(Rugby)'.tr,'Number 8(Rugby)'.tr, 'Scrum Half(Rugby)'.tr, 'Fly Half(Rugby)'.tr, 'Left Wing(Rugby)'.tr, 'Inside Center(Rugby)'.tr, 'Outside Center(Rugby)'.tr,
       'Right Wing(Rugby)'.tr,'Full Back(Rugby)'.tr, 'Wicketkeeper(Cricket)'.tr,'Slip(Cricket)'.tr, 'Gully(Cricket)'.tr,'Point(Cricket)'.tr,'Cover(Cricket)'.tr, 'Third Man(Cricket)'.tr,
 'Fine Leg(Cricket)'.tr,'Mid Wicket(Cricket)'.tr, 'Mid Off(Cricket)'.tr, 'Square Leg(Cricket)'.tr, 'Captain(Cricket)'.tr, 'Outside Hitter(Volleyball)'.tr, 'Opposite(Volleyball)'.tr,
         'Setter(Volleyball)'.tr, 'Middle Blocker(Volleyball)'.tr, 'Libero(Volleyball)'.tr, 'Defensive Specialist(Volleyball)'.tr, 'Serving Specialist(Volleyball)'.tr,
  'Center(American Football/Gridiron)'.tr, 'Offensive Guard(American Football/Gridiron)'.tr, 'Offensive Tackle(American Football/Gridiron)'.tr,
'Quarterback(American Football/Gridiron)'.tr, 'Runningback(American Football/Gridiron)'.tr,'Wide Receiver(American Football/Gridiron)'.tr,'Tight End(American Football/Gridiron)'.tr,
     'Defensive Tackle(American Football/Gridiron)'.tr, 'Defensive End(American Football/Gridiron)'.tr, 'Linebacker(American Football/Gridiron)'.tr,
            'Middle Linebacker(American Football/Gridiron)'.tr, 'Outside Linebacker(American Football/Gridiron)'.tr, 'Cornerback(American Football/Gridiron)'.tr,
             'Safety(American Football/Gridiron)'.tr, 'Nickelback and Dimeback(American Football/Gridiron)'.tr, 'Kicker(American Football/Gridiron)'.tr,
   'Kickoff Specialist(American Football/Gridiron)'.tr, 'Punter(American Football/Gridiron)'.tr, 'Holder(American Football/Gridiron)'.tr,'Long Snapper(American Football/Gridiron)'.tr,
  'Returner(American Football/Gridiron)'.tr,'Upback(American Football/Gridiron)'.tr,'Gunner(American Football/Gridiron)'.tr, 'Jammer(American Football/Gridiron)'.tr,
 'Goalkeeper(Futsal or Beach Soccer)'.tr, 'Defender(Futsal or Beach Soccer)'.tr, 'Winger(Futsal or Beach Soccer)'.tr, 'Forward(Futsal or Beach Soccer)'.tr, '100m Runner(Athletics)'.tr,
  '200m Runner(Athletics)'.tr, '400m Runner(Athletics)'.tr,'800m Runner(Athletics)'.tr, '1500m Runner(Athletics)'.tr,'Marathon Runner(Athletics)'.tr, 'Relay Runner(Athletics)'.tr,
 'Hurdle Runner(Athletics)'.tr, 'Long Jump(Athletics)'.tr, 'Triple Jump(Athletics)'.tr, 'High Jump(Athletics)'.tr, 'Pole Vault(Athletics)'.tr, 'Shot Put(Athletics)'.tr,
  'Discus Throw(Athletics)'.tr,'Javelin Throw(Athletics)'.tr,'Mixed Martial Artist(Mixed Martial Arts)'.tr,'Boxer(Boxing)'.tr,'Pitcher(Baseball)'.tr, 'Catcher(Baseball)'.tr,
 'First Baseman(Baseball)'.tr, 'Second Baseman(Baseball)'.tr,'Third Baseman(Baseball)'.tr,'Shortstop(Baseball)'.tr,'Left Fielder(Baseball)'.tr,'Right Fielder(Baseball)'.tr,
 'Center Fielder(Baseball)'.tr,'Middle Infielder(Baseball)'.tr,'Corner Infielder(Baseball)'.tr,'Batter(Baseball)'.tr,'Goalkeeper(Field Hockey)'.tr,'Defender(Field Hockey)'.tr,
 'Sweeper(Field Hockey)'.tr,'Midfielder(Field Hockey)'.tr,'Attacker(Field Hockey)'.tr,'Goalie(Ice Hockey)'.tr,'Defenseman(Ice Hockey)'.tr,'Wing(Ice Hockey)'.tr,'Center(Ice Hockey)'.tr,
'Gymnast(Gymnastics)'.tr,'Swimmer(Swimming)'.tr,'Wrestler(Wrestling)'.tr, 'Kickboxer(Kickboxing)'.tr,'Table Tennis Player(Table Tennis)'.tr,'Golfer(Golf)'.tr,'Snooker Player(Snooker)'.tr,
'Goalkeeper(Handball)'.tr,'Left Back(Handball)'.tr,'Right Back(Handball)'.tr,'Center Back(Handball)'.tr, 'Center Forward(Handball)'.tr,'Left Winger(Handball)'.tr, 'Right Winger(Handball)'.tr,
   'Weight Lifter(Weight Lifting)'.tr, 'Referee'.tr,];
    return DropdownButton<String>(
      value: filterRole,
      onChanged: (String? newValue) {
        setState(() {
          filterRole = newValue == 'Default' ? null : newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Default',
          child: Text('Default'.tr),
        ),
        ...roles.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Role'.tr),
    );
  }


  Future<void> _toggleLike(String postId, bool isLiked) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    try {
      await postRef.collection('likes').doc(currentUserId).set({
        'isLiked': !isLiked,
      });

      final likesSnapshot = await postRef.collection('likes').get();
      final likesMap = likesSnapshot.docs.fold<Map<String, dynamic>>({}, (map, doc) {
        map[doc.id] = doc['isLiked'];
        return map;
      });
      await postRef.update({
        'likes': likesMap,
      });

      final likesCount = likesSnapshot.docs.where((doc) => doc['isLiked'] == true).length;
      await postRef.update({
        'likesCount': likesCount,
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _deletePost(String postId, BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      try {
        final postSnapshot = await postRef.get();
        final postUserId = postSnapshot.data()?['uid'] as String?;
        if (postSnapshot.exists && postUserId != null) {
          if (postUserId == currentUser.uid) {
            await postRef.delete();
            await postRef.collection('comments').get().then((snapshot) {
              for (final doc in snapshot.docs) {
                doc.reference.delete();
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Post deleted successfully'.tr)),
            );

            deletedPostIds.add(postId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You are not authorized to delete this post'.tr)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post does not exist'.tr)),
          );
        }
      } catch (e) {
        print('Error deleting post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while deleting the post'.tr)),
        );
      }
    }
  }

  void _scrollListener() {
    final List<ChewieController> controllerValues = chewieControllers.values.toList();
    for (final controller in controllerValues) {
      if (controller.videoPlayerController.value.isPlaying) {
        controller.pause();
      }
    }
  }
}
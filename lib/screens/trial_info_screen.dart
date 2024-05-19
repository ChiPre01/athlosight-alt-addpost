import 'package:athlosight/group_chat/dashboard.dart';
import 'package:athlosight/screens/add_trial_post_screen.dart';
import 'package:athlosight/screens/user_profile_screen.dart';
import 'package:athlosight/widgets/visible_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:athlosight/screens/comment_screen.dart';
import 'package:athlosight/screens/my_profile_screen.dart';

class TrialInfoScreen extends StatefulWidget {
  const TrialInfoScreen({Key? key}) : super(key: key);

  @override
  State<TrialInfoScreen> createState() => _TrialInfoScreenState();
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

class _TrialInfoScreenState extends State<TrialInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<DocumentSnapshot> filteredPosts = [];
  final ScrollController _scrollController = ScrollController();
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
   // Add this variable to track whether there's more data to load
  bool _hasMore = true;

  // Add this variable to track whether data is currently being loaded
  bool _isLoading = false;

  // Add this variable to track the last document snapshot
  DocumentSnapshot? _lastDocument;


 // Add the following line
  final String _adUnitId = 'ca-app-pub-1798341219433190/4386798498'; // replace with your actual ad unit ID

  @override
  void initState() {
    super.initState();
        _fetchPosts();
    _fetchUserData();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
        _loadAd(); // Load the native ad
          // Add a listener to the scroll controller
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Reached the bottom of the list
        if (_hasMore && !_isLoading) {
          // Fetch more data
          _fetchPosts();
        }
      }
    });
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
      final postsSnapshot = await _firestore.collection('posts').get();
      final posts = postsSnapshot.docs;
      print('Fetched ${posts.length} posts');
    } catch (e) {
      print('Error fetching posts data: $e');
    }
    setState(() {});
  }

 @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
  
  Future<void> _fetchPosts() async {
  if (_isLoading) {
    return;
  }

  try {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> postsSnapshot;
    if (_lastDocument == null) {
      // Initial fetch
      postsSnapshot = await _firestore.collection('posts').get();
    } else {
      // Fetch next batch of posts
      postsSnapshot = await _firestore
          .collection('posts')
          .startAfterDocument(_lastDocument!)
          .get();
    }

    if (postsSnapshot.docs.isNotEmpty) {
      _lastDocument = postsSnapshot.docs.last;
      filteredPosts.addAll(postsSnapshot.docs);

      // Check if there's more data to load
      if (postsSnapshot.docs.length < 10) {
        _hasMore = false;
      }
    } else {
      _hasMore = false;
    }
  } catch (e) {
    print('Error fetching posts data: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


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
      const SizedBox(width: 8), // Add spacing between the image and title
      Text(
        'Trials/Camps Info',
        style: TextStyle(
          color: Colors.deepPurple, // Set the text color to deep purple
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: Icon(
        Icons.add, // Plus icon
        size: 32, // Increase icon size
        color: Colors.deepPurple, // Set icon color to deep purple
      ),
      onPressed: () {
        // Navigate to the AddTrialPostScreen when the plus icon is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTrialPostScreen(),
          ),
        );
      },
    ),
  ],
),

      body:    
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSportFilterDropdown(),
                buildCountryFilterDropdown(),
                buildAthleteGenderFilterDropdown(),
              ],
            ),
          ),
                      const SizedBox(height: 10),
         ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Dashboard(),
      ),
    );
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.mail), // Email icon
      SizedBox(width: 8), // Spacer
      Expanded(
        child: Text(
          'Create Group Chat Room or Search Group Chat Rooms',
          overflow: TextOverflow.ellipsis, // Handle text overflow
        ),
      ),
    ],
  ),
),

          Expanded(
            child: usersList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('posts').snapshots(),
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

      
                                     // Modify this condition to exclude posts with videoUrl
  return postData['videoUrl'] == null &&
      (filterLevel == null || postData['level'] == filterLevel) &&
      (filterSport == null || postData['sport'] == filterSport) &&
      (filterCountry == null || user.country == filterCountry) &&
      (filterRole == null || postData['role'] == filterRole) &&
      (filterAthleteGender == null ||
          postData['athletegender'] == filterAthleteGender);
}).toList();
      
        return ListView.builder(
  controller: _scrollController,
  itemCount: filteredPosts.length + ((filteredPosts.length ~/ 5) + 1),
  itemBuilder: (context, index) {
    if (index != 0 && index % 6 == 0 && _nativeAdIsLoaded) {
      // Index is a multiple of 6 (after the first item), return an ad widget
      return Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      // Calculate the adjusted post index for non-ad items
      final adjustedPostIndex = index - ((index ~/ 6) + 1);
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

        final sport = post['sport'] ?? '';
        final caption = post['caption'] ?? '';
        final imageUrl = post['Url'] ?? '';
        final timestampStr = post['timestamp'] as String;
        final athletegender = post['athletegender'] ?? '';


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
                          '${user.country}, $athletegender,'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('Sport: $sport',
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
             Padding(
  padding: const EdgeInsets.all(8.0),
  child: CachedNetworkImage(
    imageUrl: post['imageUrl'],
    placeholder: (context, url) => CircularProgressIndicator(),
    errorWidget: (context, url, error) => Icon(Icons.error),
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
                                  'Check out this post: $caption\n\nImage: $imageUrl';

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
                              const Text(
                                'Likes',
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
                                  const Text(
                                    'Comments',
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


  // Repeat the same pattern for other filter dropdowns

  Widget buildSportFilterDropdown() {
    final sports = ['Football/Soccer', 'Basketball', 'Tennis', 'Rugby', 'Cricket', 'Volleyball', 'American Football/Gridiron', 'Futsal/7 or 5 a side'
    'Athletics', 'Mixed Martial Arts','Boxing', 'Baseball', 'Field Hockey','Ice Hockey', 'Gymnastics', 'Swimming', 'Wrestling', 'Kickboxing', 'Table Tennis','Golf',
     'Snooker','Handball','Weight Lifting'];
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
          child: Text('Default'),
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
          child: Text('Default'),
        ),
        ...countries.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Regions'),
    );
  }


   Widget buildAthleteGenderFilterDropdown() {
    final athletegenders = [ 'Male','Female',];
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
          child: Text('Default'),
        ),
        ...athletegenders.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      hint: Text('Athlete Gender'),
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
      final likesMap =
          likesSnapshot.docs.fold<Map<String, dynamic>>({}, (map, doc) {
        map[doc.id] = doc['isLiked'];
        return map;
      });
      await postRef.update({
        'likes': likesMap,
      });

      final likesCount =
          likesSnapshot.docs.where((doc) => doc['isLiked'] == true).length;
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
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

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
              SnackBar(content: Text('Post deleted successfully')),
            );

            deletedPostIds.add(postId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('You are not authorized to delete this post')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post does not exist')),
          );
        }
      } catch (e) {
        print('Error deleting post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while deleting the post')),
        );
      }
    }
  }

}



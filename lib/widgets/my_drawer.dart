import 'package:athlosight/screens/following_post_screen.dart';
import 'package:athlosight/widgets/visible_screen.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          //logo
          DrawerHeader(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/IMG-20230529-WA0107.jpg',
                      width: 100,
                      height: 100,
                    ),
                  )
                ],
              ),
            ),
          ),
          //list tile
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("POSTS"),
            leading: Icon(Icons.home),
            onTap: (){
               //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisibleScreen(initialIndex: 0, userProfileImageUrl: '',)));
            },
          ),
        ),
         Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("FANNING"),
            leading: Icon(Icons.favorite),
            onTap: (){
               //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingPostScreen()));
            },
          ),
        ),
         Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("SEARCH"),
            leading: Icon(Icons.search),
            onTap: (){
               //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisibleScreen(initialIndex: 3, userProfileImageUrl: '',)));
            },
          ),
        ),
         Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("CREATE CONTENT"),
            leading: Icon(Icons.add),
            onTap: (){
               //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisibleScreen(initialIndex: 2, userProfileImageUrl: '',)));
            },
          ),
        ),
         Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("TRIAL / CAMP SETUP" ),
            leading: Icon(Icons.info),
            onTap: (){
                 //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisibleScreen(initialIndex: 1, userProfileImageUrl: '',)));
            },
          ),
        ),
         Padding(
          padding: const EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("PROFILE"),
            leading: Icon(Icons.person),
            onTap: (){
              //pop the drawer
              Navigator.pop(context);
              //navigate to screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisibleScreen(userProfileImageUrl: '', initialIndex: 4,)));
            },
          ),
        )
        ],
      ),
    );
  }
}

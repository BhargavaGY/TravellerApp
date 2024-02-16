import "dart:io";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final user = FirebaseAuth.instance.currentUser!;
  late String userName;
  late String? userEmail;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Sophie'),
            accountEmail: Text(user.email!),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                  child: Image.asset('lib/images/profile.jpg', fit: BoxFit.cover,width: 80, height: 80,),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('lib/images/background.jpg'), fit: BoxFit.cover,)
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.square_list_fill, color: Colors.black,),
            title: const Text('Personal Checklist'),
            onTap: (){
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.rectangle_stack_person_crop_fill, color: Colors.black,),
            title: const Text('Shared Checklist'),
            onTap: (){
              Navigator.pushNamedAndRemoveUntil(context, '/sharedtasks', (route) => false);
            },
          ),
          Divider(thickness: 1,),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black,),
            title: const Text('Sign Out'),
            onTap: ()=> signUserOut(),
          ),
        ],
      ),
    );
  }
}


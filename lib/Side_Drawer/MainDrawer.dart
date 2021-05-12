import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../GlobalVariables.dart';
import './profile.dart';
// import 'Settings.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
            color: Colors.blue,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(profileImage),
                        ))),
                SizedBox(
                  height: 20,
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              print("profile");
              Navigator.of(context).push(MaterialPageRoute(builder: (c) => ProfilePage())).then((value) {
                setState(() {
                  print('object');
                });
              });
            },
            leading: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            title: Text(
              "Profile",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          // ListTile(
          //   onTap: (0) {
          //     print("settings");
          //     Navigator.of(context).push(MaterialPageRoute(builder: (c) => Settings()));
          //   },
          //   leading: Icon(
          //     Icons.settings,
          //     color: Colors.blueAccent,
          //   ),
          //   title: Text(
          //     "Settings",
          //     style: TextStyle(
          //       fontSize: 22,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

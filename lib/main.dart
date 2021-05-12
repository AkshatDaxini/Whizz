import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './send_receive/BottomNavBar.dart';
import './Apps/AppTab.dart';
import './Images/ImageTab.dart';
import './Application_Intialization/SplashScreen.dart';
import './Audio/screens/AudioTab.dart';
import './Videos.dart';
import './Side_Drawer/MainDrawer.dart';
import './GlobalVariables.dart';
import './historyTab.dart';

void main() => runApp(MyApp());

class Main extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SelectedItems>(create: (ctx) => SelectedItems()),
        ChangeNotifierProvider<Connection>(create: (ctx) => Connection()),
      ],
      child: MaterialApp(
        home: DefaultTabController(
          initialIndex: 1,
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Whizz'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.history), text: "History"),
                  Tab(icon: Icon(Icons.android), text: "Applications"),
                  Tab(icon: Icon(Icons.photo), text: "Photos"),
                  Tab(icon: Icon(Icons.video_library), text: "Videos"),
                  Tab(icon: Icon(Icons.audiotrack), text: "Audio"),
                  // Tab(icon: Icon(Icons.folder), text: "Files"),
                ],
              ),
            ),
            drawer: MainDrawer(),
            body: TabBarView(
              children: [
                HistoryTab(),
                Apps(),
                Images(),
                Videos(),
                Audio(),
              ],
            ),
            bottomNavigationBar: BottomNavBar(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

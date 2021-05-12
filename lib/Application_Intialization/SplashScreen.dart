import 'package:flutter/material.dart';

import 'package:splashscreen/splashscreen.dart';

import '../main.dart';
import 'Initialization.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SplashScreen(
          // seconds: 5,
          navigateAfterFuture: loadFromFuture(),
          title: Text(
            'Whizz',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38.0),
          ),
          gradientBackground: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.white, Colors.blue],
          ),
          backgroundColor: Colors.white,
          loaderColor: Colors.white,
          useLoader: true,
          loadingText: Text(
            "Loading ...",
            style: TextStyle(color: Colors.black45, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Future<Widget> loadFromFuture() async {
    await getPermission();
    await createDir();
    await getApps();
    await getSystemApps();
    await fetchImages();
    await getAudio();
    await fetchVideos();
    await getDeviceInfo();
    return Future.value(Main());
  }
}

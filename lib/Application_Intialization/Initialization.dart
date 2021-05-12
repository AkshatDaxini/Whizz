import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../GlobalVariables.dart';
import '../Audio/model/album.dart';
import '../Audio/model/song.dart';

//Function to get permissions
getPermission() async {
  final storagestatus = await Permission.storage.status;
  final locationStatus = await Nearby().checkLocationPermission();
  if (!storagestatus.isGranted) {
    await Permission.storage.request();
  }
  if (!locationStatus) {
    await Nearby().askLocationPermission();
  }
  if (storagestatus.isPermanentlyDenied) openAppSettings();
}

// Function to get installed apps
getApps() async {
  installedapps = await DeviceApps.getInstalledApplications(includeAppIcons: true, onlyAppsWithLaunchIntent: true);
  installedapps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
}

//Function to get system apps
Future getSystemApps() async {
  systemapps = await DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    includeSystemApps: true,
    onlyAppsWithLaunchIntent: true,
  );
  systemapps.removeWhere((item) => item.systemApp != true);
  systemapps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
}

//Function to get songs and audio albums
Future getAudio() async {
  albumList = await Album().getDeviceAlbums();
  songList = await Song().getDeviceSongs();
}

//Function to get device images
Future fetchImages() async {
  final albumList = await PhotoManager.getAssetPathList(type: RequestType.image);
  recentAlbum = await albumList[0].assetList;
  albumList.removeAt(0);
  imageAlbumList = albumList;
}

//Function to get device videos
fetchVideos() async {
  final albumsList = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.video, hasAll: true);
  var recentVideos = await albumsList[0].assetList;
  videoAlbum = recentVideos;
}

//Function to get device info
getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final fileData = await userData.readAsString();
  if (fileData.isEmpty) {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        userName = androidInfo.model;
        modelName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        userName = iosInfo.model;
      }
    } on PlatformException {
      userName = 'User';
    }
    profileImage = "photos/1.jpeg";
    userData.writeAsString("$userName:$profileImage", mode: FileMode.write);
  } else {
    final tempUserName = fileData.split(':')[0];
    if (tempUserName.isNotEmpty) {
      userName = tempUserName;
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      modelName = androidInfo.model;
    }
    final tempProfieImage = fileData.split(':')[0];
    if (tempProfieImage.isNotEmpty) {
      profileImage = tempProfieImage;
    }
  }
}

createDir() async {
  //Create Whizz folder in internal storage
  final path = Directory('/storage/emulated/0/Whizz');
  if (!await path.exists()) path.create();
  appPath = path;

  //Create temp folder in Whizz folder
  final tempPath = Directory('/storage/emulated/0/Whizz/temp');
  if (!await tempPath.exists()) tempPath.create();
  appTempPath = tempPath;

  //Create history.txt file in Whizz folder
  final historyPath = File('${path.path}/history.txt');
  if (!await historyPath.exists()) historyPath.create();
  historyLogs = historyPath;

  //Create userData.txt file in Whizz document folder
  final appDir = await getApplicationDocumentsDirectory();
  final userDataPath = File('${appDir.path}/userData.txt');
  if (!await userDataPath.exists()) userDataPath.create();
  userData = userDataPath;
}

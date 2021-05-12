import 'dart:io';

import 'package:flutter/material.dart';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import './ReceiveContent.dart';
import './SendContent.dart';
import '../GlobalVariables.dart';

locationPermission() async {
  if (await Nearby().checkLocationPermission()) {
    locationServices();
  } else {
    await Nearby().askLocationPermission();
    if (await Permission.location.isPermanentlyDenied) openAppSettings();
  }
}

locationServices() async {
  if (await Nearby().checkLocationEnabled()) {
  } else {
    await Nearby().enableLocationServices();
  }
}

sendButton(c) async {
  await locationPermission();
  Navigator.of(c).push(MaterialPageRoute(
    builder: (_) {
      return SendContent();
    },
  ));
}

receiveButton(c) async {
  await locationPermission();
  print('receive');
  Navigator.of(c).push(MaterialPageRoute(
    builder: (_) {
      return ReceiveContent();
    },
  ));
}

void showSnackbar(BuildContext c, dynamic a) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(
    content: Text(a.toString()),
  ));
}

void logHistory(String logEntry, bool failed, String user) {
  if (user == "sent") {
    historyLogs.writeAsString(
      user + ":" + failed.toString() + ':' + logEntry + "\n",
      mode: FileMode.append,
    );
  } else {
    historyLogs.writeAsString(
      user + ":" + failed.toString() + ':' + logEntry + "\n",
      mode: FileMode.append,
    );
  }
}

String getApkName(String path) {
  String name = path.split('-').first;
  return name;
}

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:device_apps/device_apps.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:nearby_connections/nearby_connections.dart';

import './Audio/model/album.dart';
import './Audio/model/song.dart';

const Color isSelected_color = Colors.blue;
const default_font_color = Colors.black;
const Color defalut_bg_color = Colors.white;

Directory appPath;
Directory appTempPath;
File historyLogs;
File userData;
String modelName;
String profileImage;

//apps
List<Application> installedapps;
List<Application> systemapps;

//audio
List<Album> albumList;
List<Song> songList;

//send receive
String userName; // name of user = device name
final Strategy strategy = Strategy.P2P_STAR;

Map<int, String> map = Map(); //store filename mapped to corresponding payloadId
Map<String, bool> isEncrypted = Map(); //<id,bool>

bool isAdvertising = false;
bool isDiscovering = false;
File tempFile; //file after being received is stored here

//image
List<AssetEntity> recentAlbum;
List<AssetPathEntity> imageAlbumList;

//video
List<AssetEntity> videoAlbum = [];

// control of selected items
class SelectedItems with ChangeNotifier {
  List<String> _selectedItems = [];
  bool isEmpty = true;

  List<String> get selectedItems {
    return [..._selectedItems];
    // return _selectedItems;
  }

  void add(String filePath) {
    isEmpty = false;
    _selectedItems.add(filePath);
    notifyListeners();
  }

  void remove(String filePath) {
    _selectedItems.remove(filePath);
    notifyListeners();
  }

  int get count {
    return _selectedItems.length;
  }

  void clear() {
    isEmpty = true;
    _selectedItems.clear();
    notifyListeners();
  }
}

class Connection with ChangeNotifier {
  // connected device list
  static Map<String, ConnectionInfo> _peerList = Map();

  void addPeer(String id, ConnectionInfo connInfo) {
    _peerList[id] = connInfo;
    notifyListeners();
  }

  void removePeer(String id) {
    _peerList.remove(id);
    notifyListeners();
  }

  void clearPeerList() {
    _peerList.clear();
    notifyListeners();
  }

  Map<String, ConnectionInfo> get peerList {
    return {..._peerList};
  }

  int get peerListLength {
    return _peerList.length;
  }

  // list of requesting devices , incoming devices list
  static Map<String, ConnectionInfo> _incomingConnections = Map();

  void addIncomingConnection(String id, ConnectionInfo connInfo) {
    _incomingConnections[id] = connInfo;
    print(_incomingConnections[id].endpointName);
    notifyListeners();
  }

  void removeIncommingConnection(String id) {
    _incomingConnections.remove(id);
    notifyListeners();
  }

  Map<String, ConnectionInfo> get incomingConnections {
    return {..._incomingConnections};
  }

  int get inConnLength {
    return _incomingConnections.length;
  }

  // list of devices to which connection is requested, outgoing requests
  static Map<String, ConnectionInfo> _outgoingConnections = Map(); //<id,conInfo>

  void addOutgoingConnection(String id, ConnectionInfo connInfo) {
    _outgoingConnections[id] = connInfo;
    notifyListeners();
  }

  void removeOutgoingConnection(String id) {
    _outgoingConnections.remove(id);
    notifyListeners();
  }

  Map<String, ConnectionInfo> get outgoingConnections {
    return {..._outgoingConnections};
  }

  int get outConnLength {
    return _outgoingConnections.length;
  }

  // list of devices available nearby to which connection can be requested
  static Map<String, String> _connectionFound = Map(); //<id,name>

  void addAvailableConn(String id, String name) {
    _connectionFound[id] = name;
    notifyListeners();
  }

  void removeAvailableConn(String id) {
    _connectionFound.remove(id);
    notifyListeners();
  }

  void clearConnFound() {
    _connectionFound.clear();
    notifyListeners();
  }

  void updateConnName(String id, String name) {
    _connectionFound[id] = name;
    notifyListeners();
  }

  Map<String, String> get connectionFound {
    return {..._connectionFound};
  }

  int get connFoundLength {
    return _connectionFound.length;
  }

  // current files in transfer
  Map<int, Map<String, dynamic>> _transferringFiles = Map();

  void addTarnsferingFile(int id, String file) {
    _transferringFiles[id] = {
      'file': file,
      'totalBytes': 1,
      'currentBytes': 0,
      'completed': false,
    };
    notifyListeners();
  }

  void updateTransferingFile(int id, int currentBytes, int totalBytes) {
    _transferringFiles[id]['currentBytes'] = currentBytes;
    _transferringFiles[id]['totalBytes'] = totalBytes;
    notifyListeners();
  }

  void statsUpdate(int id, String status) {
    _transferringFiles[id]['status'] = status;
    notifyListeners();
  }

  void updateFileName(int id, String name) {
    _transferringFiles[id]['file'] = name;
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> get transferFiles {
    return {..._transferringFiles};
  }
}

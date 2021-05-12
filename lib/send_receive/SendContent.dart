import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:provider/provider.dart';
import 'package:ripple_animation/ripple_animation.dart';
import 'package:vibrate/vibrate.dart';

import './connectionSettings.dart';
import '../GlobalVariables.dart';
import './encryptDecrypt.dart';
import './OngoingTransfer.dart';

class SendContent extends StatefulWidget {
  SendContent({Key key}) : super(key: key);

  @override
  _SendContentState createState() => _SendContentState();
}

class _SendContentState extends State<SendContent> {
  @override
  void initState() {
    super.initState();
    if (!isAdvertising) _startAdvertising();
  }

  _startAdvertising() async {
    try {
      isAdvertising = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (id, info) {
          // vibrateDevice(FeedbackType.light);
          if (info.isIncomingConnection) {
            setState(() {
              Connection().addIncomingConnection(id, info);
            });
            print("lenght: " + Connection().incomingConnections.length.toString());
            // incomingConnections[id] = info;
            showSnackbar(context, "New Connection Found");
            // setState(() {});
          }
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            Connection().addPeer(id, Connection().incomingConnections[id]);
            // endpointMap[id] = incomingConnections[id];
            isEncrypted[id] = false;
            Connection().removeIncommingConnection(id);
            // incomingConnections.remove(id);
            vibrateDevice(FeedbackType.success);
            showSnackbar(context, 'Connected to ${Connection().peerList[id].endpointName}');
            setState(() {});
          } else
            // if (status == Status.REJECTED)
              {
            showSnackbar(context, 'Request rejected by ${Connection().incomingConnections[id].endpointName}');
            print("Sender side");
            Connection().removeIncommingConnection(id);
            // incomingConnections.remove(id);
            setState(() {});
          }
        },
        onDisconnected: (id) {
          Nearby().disconnectFromEndpoint(id);
          showSnackbar(context, "Disconnected form ${Connection().peerList[id].endpointName}");
          Connection().removePeer(id);
          vibrateDevice(FeedbackType.error);
          // endpointMap.remove(id);
          setState(() {});
        },
      );
      showSnackbar(context, "Searching");
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _selectedItems = Provider.of<SelectedItems>(context);
    final _connection = Provider.of<Connection>(context);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () async {
            await Nearby().stopAdvertising();
            isAdvertising = false;
            showSnackbar(context, "Stopped Searching");
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .1),
              child: RippleAnimation(
                ripplesCount: 3,
                color: Colors.grey[500],
                repeat: true,
                minRadius: MediaQuery.of(context).size.width * .15,
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_tethering,
                      size: MediaQuery.of(context).size.width * .1,
                    ),
                    Text("Network Created"),
                    Text("Waiting for receivers"),
                  ],
                ),
              ),
            ),
            _connection.inConnLength > 0
                ? Container(
              height: MediaQuery.of(context).size.height * .06,
              alignment: Alignment.center,
              color: Colors.blue,
              child: Text(
                "Incoming Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            )
                : Container(),
            _connection.inConnLength > 0
                ? Flexible(
              flex: 3,
              child: ListView.separated(
                  separatorBuilder: (_, i) => Divider(),
                  itemCount: _connection.inConnLength,
                  itemBuilder: (_, i) {
                    var id = _connection.incomingConnections.keys.toList()[i];
                    var info = _connection.incomingConnections[id];
                    return ListTile(
                      title: Text(info.endpointName),
                      trailing: Container(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              //Accept the connection
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                Nearby().acceptConnection(
                                  id,
                                  onPayLoadRecieved: (endid, payload) async {
                                    if (payload.type == PayloadType.BYTES) {
                                      String str = String.fromCharCodes(payload.bytes);
                                      // showSnackbar(context, endid + ": " + str);
                                      if (str.contains(':')) {
                                        // used for file payload as file payload is mapped as
                                        // payloadId:filename
                                        int payloadId = int.parse(str.split(':')[0]);
                                        String name = (str.split(':')[1]);
                                        _connection.updateFileName(payloadId, name);

                                        if (map.containsKey(payloadId)) {
                                          if (await tempFile.exists()) {
                                            if (name.endsWith(".aes")) {
                                              var dfile =
                                              File(await EncryptData.decryptFile(context, tempFile.path));
                                              dfile.rename(
                                                  appPath.path + "/" + name.substring(0, name.length - 4));
                                              tempFile.delete();
                                            } else {
                                              tempFile.rename(appPath.path + "/" + name);
                                            }
                                            // var path = tempFile.path;

                                          } else {
                                            print('file doesnt exist');
                                          }
                                        } else {
                                          //add to map if not already
                                          map[payloadId] = name;
                                          print("-**********name:" + name);
                                          _connection.updateFileName(payloadId, name);
                                        }
                                      }
                                    } else if (payload.type == PayloadType.FILE) {
                                      // showSnackbar(context, endid + ": File transfer started");
                                      print("file transferr started");
                                      _connection.addTarnsferingFile(payload.id, payload.filePath);
                                      tempFile = File(payload.filePath);
                                      // return Navigator.of(context).
                                    }
                                  },
                                  onPayloadTransferUpdate: (endid, payloadTransferUpdate) async {
                                    if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRESS) {
                                      _connection.updateTransferingFile(
                                        payloadTransferUpdate.id,
                                        payloadTransferUpdate.bytesTransferred,
                                        payloadTransferUpdate.totalBytes,
                                      );
                                      _connection.statsUpdate(payloadTransferUpdate.id, "inprogress");

                                      print(payloadTransferUpdate.bytesTransferred);
                                    } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
                                      print("failed");
                                      _connection.statsUpdate(payloadTransferUpdate.id, "failed");
                                      print(endid + ": FAILED to transfer file");
                                      logHistory(payloadTransferUpdate.id.toString(), true, "recevier");
                                    } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
                                      print("$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");
                                      _connection.statsUpdate(payloadTransferUpdate.id, "success");

                                      if (map.containsKey(payloadTransferUpdate.id)) {
                                        //rename the file now
                                        String name = map[payloadTransferUpdate.id];
                                        _connection.updateFileName(payloadTransferUpdate.id, name);

                                        if (name.endsWith(".aes")) {
                                          var dfile = File(await EncryptData.decryptFile(context, tempFile.path));
                                          await dfile
                                              .rename(appPath.path + "/" + name.substring(0, name.length - 4))
                                              .then((value) {
                                            logHistory(value.path, false, "recevier");
                                          });
                                          tempFile.delete();
                                        } else {
                                          await tempFile.rename(appPath.path + "/" + name).then((value) {
                                            logHistory(value.path, false, "recevier");
                                          });
                                        }

                                        // tempFile=dfile;
                                      } else {
                                        //bytes not received till yet
                                        map[payloadTransferUpdate.id] = "";
                                        // _selectedItems.addTarnsferingFile(payloadTransferUpdate.id,name);
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                            IconButton(
                              //Reject the connection
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                // await Nearby().rejectConnection(id);
                                // setState(() {});
                                try {
                                  await Nearby().rejectConnection(id);
                                  _connection.removeIncommingConnection(id);
                                } catch (e) {
                                  print(e);
                                  showSnackbar(context, "Connection Failed");
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            )
                : Container(),
            Divider(),
            _connection.peerListLength > 0
                ? Container(
              height: MediaQuery.of(context).size.height * .06,
              color: Colors.blue,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.cancel_outlined, color: Colors.red, size: 32),
                      tooltip: 'Disconnect all devices',
                      onPressed: () async {
                        await Nearby().stopAllEndpoints();
                        // setState(() {
                        //   endpointMap.clear();
                        // });
                        _connection.clearPeerList();
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Connected devices",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.send_sharp, color: Colors.white, size: 32),
                      tooltip: 'Send to all devices',
                      onPressed: () async {
                        if (_selectedItems.count < 1) {
                          showSnackbar(context, 'No Files Selected!!');
                          Navigator.pop(context);
                        } else {
                          List<String> transferringQueue = _selectedItems.selectedItems;
                          _selectedItems.clear();
                          for (String file in transferringQueue) {
                            for (MapEntry<String, ConnectionInfo> m in _connection.peerList.entries) {
                              if (isEncrypted[m.key]) file = await EncryptData.encryptFile(context, file);
                              int payloadId = await Nearby().sendFilePayload(m.key, file);
                              // setState(() {
                              _connection.addTarnsferingFile(payloadId, file);
                              //   // _selectedItems.remove(file);
                              // });
                              print("Sending file to $m.key");
                              if (file.endsWith(".apk")) file = file.split('-').first + '.apk';
                              if (file.endsWith(".apk.aes")) file = file.split('-').first + '.apk.aes';
                              Nearby().sendBytesPayload(
                                  m.key, Uint8List.fromList("$payloadId:${file.split('/').last}".codeUnits));
                            }
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OngoingTransfer()));
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
                : Container(),
            _connection.peerListLength > 0
                ? Flexible(
              flex: 3,
              child: ListView.builder(
                itemCount: _connection.peerListLength,
                itemBuilder: (_, i) {
                  final id = _connection.peerList.keys.toList()[i];
                  final info = _connection.peerList[id];
                  return ListTile(
                    title: Text(info.endpointName),
                    trailing: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel),
                            color: Colors.red,
                            onPressed: () {
                              Nearby().disconnectFromEndpoint(id);
                              showSnackbar(context, "Disconnected from " + info.endpointName);
                              // setState(() {
                              _connection.removePeer(id);
                              print(_connection.peerListLength);
                              // });
                            },
                          ),
                          IconButton(
                            icon: isEncrypted[id]
                                ? Icon(Icons.enhanced_encryption)
                                : Icon(Icons.no_encryption_gmailerrorred_rounded),
                            color: isEncrypted[id] ? Colors.green : Colors.black,
                            tooltip: "Encryption",
                            onPressed: () {
                              setState(() {
                                isEncrypted[id] = !isEncrypted[id];
                              });
                              if (isEncrypted[id]) {
                                showSnackbar(context, "Encryption on");
                                print(isEncrypted[id]);
                              } else {
                                showSnackbar(context, "Encryption off");
                                print(isEncrypted[id]);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            color: Colors.blue,
                            onPressed: () async {
                              if (_selectedItems.count < 1) {
                                showSnackbar(context, 'No Files Selected!!');
                                Navigator.pop(context);
                              } else {
                                List<String> transferringQueue = _selectedItems.selectedItems;
                                _selectedItems.clear();
                                for (String file in transferringQueue) {
                                  if (isEncrypted[id] ?? false) {
                                    file = await EncryptData.encryptFile(context, file);
                                  }
                                  int payloadId = await Nearby().sendFilePayload(id, file);
                                  // setState(() {
                                  _connection.addTarnsferingFile(payloadId, file);
                                  //   // _selectedItems.remove(file);
                                  // });
                                  //showSnackbar(context, "Sending file to $id");
                                  if (file.endsWith(".apk")) file = file.split('-').first + '.apk';
                                  if (file.endsWith(".apk.aes")) file = file.split('-').first + '.apk.aes';
                                  logHistory(file, false, "sent");
                                  Nearby().sendBytesPayload(
                                      id, Uint8List.fromList("$payloadId:${file.split('/').last}".codeUnits));
                                }

                                return Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => OngoingTransfer()),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
                : Flexible(
              flex: 5,
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.center,
                  // color: Colors.grey,
                  child: Text(
                    "NO \n DEVICES \n CONNECTED",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Divider(),

          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: _connection.transferFiles.length > 0,
        child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            child: Icon(
              Icons.save_alt_outlined,
            ),
            onPressed: () {
              return Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => OngoingTransfer()),
              );
            }),
      ),
    );
  }

  vibrateDevice(FeedbackType type) async {
    Vibrate.feedback(type);
    bool canVibrate = await Vibrate.vibrate();
    print(canVibrate);
  }

// static Future<String> readFromFile(File temp)async{
//   try{
//     String content;
//     content = await temp.readAsString().toString();
//
//   }catch(e){
//       print(e);
//   }
// }
}

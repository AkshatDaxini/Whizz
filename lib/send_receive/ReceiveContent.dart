import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:provider/provider.dart';
import 'package:ripple_animation/ripple_animation.dart';

import '../GlobalVariables.dart';
import './customizedWidgets.dart';
import './connectionSettings.dart';
import './encryptDecrypt.dart';
import './OngoingTransfer.dart';

class ReceiveContent extends StatefulWidget {
  ReceiveContent({Key key}) : super(key: key);

  @override
  _ReceiveContentState createState() => _ReceiveContentState();
}

class _ReceiveContentState extends State<ReceiveContent> {
  @override
  void initState() {
    super.initState();
    if (!isDiscovering)
      startDiscovering();
    else
      // showSnackbar(context, 'Already discovering');
      print('Already Discovering');
  }

  void startDiscovering() async {
    try {
      isDiscovering = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (!Connection().peerList.containsKey(id) && !Connection().outgoingConnections.containsKey(id)) {
            if (Connection().connectionFound.containsKey(id))
              Connection().updateConnName(id, name);
            else
              Connection().addAvailableConn(id, name);
            setState(() {});
          }
        },
        onEndpointLost: (id) {
          // showSnackbar(context, "Lost discovered Endpoint: ${endpointMap[id].endpointName}, id $id");
          print("Endpoint lost: ${Connection().peerList[id].endpointName}, id $id");
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _connection = Provider.of<Connection>(context);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () async {
            await Nearby().stopDiscovery();
            isDiscovering = false;
            showSnackbar(context, "Stopped Discovering");
            Connection().clearConnFound();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
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
                    Icons.wifi,
                    size: MediaQuery.of(context).size.width * .1,
                  ),
                  Text("Searching for senders"),
                ],
              ),
            ),
          ),
          _connection.connFoundLength > 0
              ? Container(
                  height: MediaQuery.of(context).size.height * .06,
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: Text(
                    "Available Connections",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                )
              : Container(),
          _connection.connFoundLength > 0
              ? Flexible(
                  flex: 3,
                  child: ListView.separated(
                    separatorBuilder: (_, i) => Divider(),
                    itemCount: _connection.connFoundLength,
                    itemBuilder: (_, i) {
                      var id = _connection.connectionFound.keys.toList()[i];
                      var name = _connection.connectionFound[id];
                      return ListTile(
                        title: Text(name),
                        trailing: OneTapElevatedButton(
                          child1: Text('Request'),
                          child2: Text('Requested'),
                          onPressed: () {
                            Nearby().requestConnection(
                              userName,
                              id,
                              onConnectionInitiated: (id, info) {
                                print('initiated');
                                _connection.addOutgoingConnection(id, info);
                                _connection.removeAvailableConn(id);
                                // setState(() {});
                              },
                              onConnectionResult: (id, status) {
                                if (status == Status.CONNECTED) {
                                  _connection.addPeer(id, _connection.outgoingConnections[id]);
                                  isEncrypted[id] = false;
                                  _connection.removeOutgoingConnection(id);
                                  Nearby().stopDiscovery();
                                  isDiscovering = false;
                                  showSnackbar(context, 'Connected to ${_connection.peerList[id].endpointName}');
                                  // setState(() {});
                                } else {
                                  showSnackbar(context,
                                      'Failed to connect to ${_connection.outgoingConnections[id].endpointName}');
                                  _connection.removeOutgoingConnection(id);
                                  // setState(() {});
                                }
                              },
                              onDisconnected: (id) {
                                Nearby().disconnectFromEndpoint(id);
                                showSnackbar(context, "Disconnected from ${_connection.peerList[id].endpointName}");
                                _connection.removePeer(id);
                                // setState(() {});
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          _connection.outConnLength > 0
              ? Container(
                  height: MediaQuery.of(context).size.height * .06,
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: Text(
                    "Requested Connections",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                )
              : Container(),
          _connection.outConnLength > 0
              ? Flexible(
                  flex: 3,
                  child: ListView.separated(
                    separatorBuilder: (_, i) => Divider(),
                    itemCount: _connection.outConnLength,
                    itemBuilder: (_, i) {
                      var id = _connection.outgoingConnections.keys.toList()[i];
                      var info = _connection.outgoingConnections[id];
                      return ListTile(
                        title: Text(info.endpointName),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              OneTapIconButton(
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
                                                var dfile = File(await EncryptData.decryptFile(context, tempFile.path));
                                                dfile.rename(appPath.path + "/" + name.substring(0, name.length - 4));
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
                              OneTapIconButton(
                                //Reject the connection
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  try {
                                    await Nearby().rejectConnection(id);
                                    _connection.removeOutgoingConnection(id);
                                    Nearby().stopDiscovery();
                                    startDiscovering();
                                    // setState(() {});
                                  } catch (e) {
                                    print(e);
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
              : Container(),
          _connection.peerListLength > 0
              ? Container(
                  height: MediaQuery.of(context).size.height * .06,
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: Text(
                    "Connected Devices",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
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
                        trailing: ElevatedButton(
                          style:
                              ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.red)),
                          child: Text('Disconnect'),
                          onPressed: () {
                            Nearby().disconnectFromEndpoint(id);
                            showSnackbar(context, "Disconnected from " + info.endpointName);
                            _connection.removePeer(id);
                            setState(() {
                              if (!isDiscovering) {
                                startDiscovering();
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                )
              : Container(),
        ],
      ),
      floatingActionButton: Visibility(
        visible: map.length > 0,
        child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.save_alt_outlined),
            onPressed: () {
              return Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => OngoingTransfer()),
              );
            }),
      ),
    );
  }
}

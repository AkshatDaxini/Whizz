import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whizz/GlobalVariables.dart';
import 'package:open_file/open_file.dart';

class HistoryTab extends StatefulWidget {
  HistoryTab({Key key}) : super(key: key);
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: history.length != 0
                  ? ListView.separated(
                      separatorBuilder: (_, i) => Divider(),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        var data = history[i].split(':');
                        return ListTile(
                          onTap: () {
                            OpenFile.open(data[2]);
                          },
                          leading: CircleAvatar(
                            child: getIcon(data[2]),
                          ),
                          // tileColor: data[1] == "true" ?Colors.red[200]:Colors.green[200],
                          title: Text(
                            data[2].split('/').last,
                            softWrap: true,
                            maxLines: 1,
                          ),
                          subtitle: data[1] == "true"
                              ? Text(
                                  "Failed",
                                  style: TextStyle(color: Colors.red),
                                )
                              : Text(
                                  "Success",
                                  style: TextStyle(color: Colors.green),
                                ),
                          trailing: data[0] == "sent"
                              ? Icon(
                                  Icons.north_east,
                                  color: Colors.blueAccent,
                                )
                              : Icon(
                                  Icons.south_west,
                                  color: Colors.blueAccent,
                                ),
                        );
                      })
                  : Container(
                      child: Center(
                        child: Text(
                          "No History",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: history.length != 0
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.delete_outline,
                size: 30,
              ),
              onPressed: () {
                historyLogs.writeAsString('', mode: FileMode.write);
                print("deleted");
                setState(() {
                  history.clear();
                });
              },
            )
          : Container(),
    );
  }

  void getHistory() async {
    await historyLogs.readAsLines().then((value) => history = value);
    print("len : " + history.length.toString());
    setState(() {});
  }

  getIcon(String data) {
    var extension = data.split('.').last;
    if (extension == 'jpeg' || extension == "png" || extension == "gif" || extension == "jpg") {
      return Icon(Icons.image_outlined);
    } else if (extension == "mp4" || extension == "mkv" || extension == "avi") {
      return Icon(Icons.movie_creation_outlined);
    } else if (extension == "mp3") {
      return Icon(Icons.music_note_outlined);
    } else if (extension == "aes") {
      return Icon(Icons.enhanced_encryption_outlined);
    } else if (extension == "apk") {
      return Icon(Icons.android_outlined);
    } else {
      return Icon(Icons.broken_image_outlined);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:filesize/filesize.dart';

import '../GlobalVariables.dart';
import './connectionSettings.dart';

class OngoingTransfer extends StatefulWidget {
  @override
  _OngoingTransferState createState() => _OngoingTransferState();
}

class _OngoingTransferState extends State<OngoingTransfer> {
  @override
  Widget build(BuildContext context) {
    // final _listOfTansferringFiles = Provider.of<SelectedItems>(context).selectedItems;
    final _transferringFiles = Provider.of<Connection>(context).transferFiles;
    // _listOfTansferringFiles.clear();
    // print("Selected list cleared" + _selectedItems.count.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfers"),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: ListView.separated(
                separatorBuilder: (_, i) => Divider(),
                itemCount: _transferringFiles.length ?? 0,
                itemBuilder: (_, i) {
                  var pid = _transferringFiles.keys.toList()[i];
                  // var map = transferringFiles[pid];
                  String title = _transferringFiles[pid]['file'].toString().split('/').last;
                  return TransferTile(
                    status: _transferringFiles[pid]['status'],
                    title: title,
                    path: _transferringFiles[pid]['file'],
                    sent: _transferringFiles[pid]['currentBytes'],
                    total: _transferringFiles[pid]['totalBytes'],
                    id: _transferringFiles[pid]['id'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransferTile extends StatefulWidget {
  TransferTile({Key key, this.title, this.path, this.sent, this.total, this.status, this.id}) : super(key: key);
  final title;
  final path;
  final sent;
  final total;
  var status;
  final id;
  @override
  _TransferTileState createState() => _TransferTileState();
}

class _TransferTileState extends State<TransferTile> {
  // Color transfer_color = Colors.green[300];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: () async {
          print(widget.path);
          await OpenFile.open(widget.path);
        },
        child: Stack(
          children: [
            LinearProgressIndicator(
              minHeight: 70,
              valueColor: new AlwaysStoppedAnimation<Color>(getProgressBarColor(widget.status)),
              value: widget.sent / widget.total,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: getThumbnail(widget.title),
              ),
              title: Text(
                widget.title.endsWith(".apk") ? getApkName(widget.path) : widget.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15),
              ),
              subtitle: Text('${filesize(widget.sent)} / ${filesize(widget.total)}'),
              trailing: InkWell(
                  onTap: () {
                    if (widget.status == "inprogress") {
                      Nearby().cancelPayload(widget.id);
                      widget.status = "failed";
                      setState(() {});
                    }
                  },
                  child: getIcon()),
            ),
          ],
        ),
      ),
    );
  }

  Color getProgressBarColor(String status) {
    if (status == "success") {
      // logHistory(widget.path, false);
      return Colors.white;
    } else if (status == "inprogress") {
      return Colors.green;
    } else if (status == "failed") {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Widget getIcon() {
    if (widget.status == "success") {
      // logHistory(widget.path, false);
      return Icon(
        Icons.file_download_done,
        color: Colors.green,
      );
    } else if (widget.status == "inprogress") {
      return Icon(
        Icons.cancel_outlined,
        color: Colors.red,
      );
    } else if (widget.status == "failed") {
      return Icon(
        Icons.error,
        color: Colors.red,
      );
    } else {
      return Icon(Icons.pending);
    }
  }

  getThumbnail(title) {
    var extension = widget.title.split('.').last;
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

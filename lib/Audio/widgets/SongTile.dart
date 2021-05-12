import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../GlobalVariables.dart';
import '../model/song.dart';

class SongTile extends StatefulWidget {
  SongTile({
    this.song,
    this.onParentClick,
  });
  final Song song;
  final onParentClick;

  @override
  _SongTileState createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _selectedItems = Provider.of<SelectedItems>(context, listen: true);
    if(_selectedItems.isEmpty) {
      widget.song.isSelected = false;
    }
    return ListTile(
      leading: InkWell(
        onTap:(){
          OpenFile.open(widget.song.filePath);
        },
          child: getThumbnail(widget.song.albumArtwork),
      ),
      title: Text(
        widget.song.displayName,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
      subtitle: Text(
          widget.song.album +
              ' | ' +
              '${parseToMinutesSeconds(int.parse(widget.song.duration))} min' +
              '\n${filesize(widget.song.fileSize)}',
          style: TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          softWrap: false),
      selected: widget.song.isSelected,
      trailing: widget.song.isSelected
          ? Icon(
              Icons.check_circle,
              color: Colors.blue,
            )
          : null,
      onTap: () {
        setState(() {
          widget.song.isSelected = !widget.song.isSelected;
          widget.song.isSelected
              ? _selectedItems.add(widget.song.filePath)
              : _selectedItems.remove(widget.song.filePath);
          print(_selectedItems.selectedItems);
          if (widget.onParentClick != null) {
            widget.onParentClick(widget.song.isSelected);
          }
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }

  Widget getThumbnail(var thumbnail) {
    if (thumbnail == null) {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text("MP3"),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.file(File(thumbnail),
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text("MP3"),
                )),
      );
    }
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:filesize/filesize.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import '../GlobalVariables.dart';

class AppTile extends StatefulWidget {
  AppTile({Key key, this.app}) : super(key: key);
  final ApplicationWithIcon app;
  @override
  _AppTileState createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> with AutomaticKeepAliveClientMixin {
  int index = 0;
  bool _isSelected = false;
  Color _bgcolor = Colors.white;
  Color _fontcolor = Colors.black;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _selectedItems = Provider.of<SelectedItems>(context, listen: false);
    final appSize = filesize(File(widget.app.apkFilePath).lengthSync());
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Container(
          // decoration: BoxDecoration(border: Border.all(width: 1)),
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          color: _bgcolor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const SizedBox(
                //   height: 5,
                // ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                      radius: 19.5,
                      backgroundImage: MemoryImage(widget.app.icon),
                      backgroundColor: Colors.white),
                ),
                // const SizedBox(
                //   height: 5,
                // ),
                Container(
                  child: Text(
                    widget.app.appName,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _fontcolor,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    appSize,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: _fontcolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isSelected)
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              child: Center(
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSelected = !_isSelected;
            });

            _isSelected
                ? _selectedItems.add(widget.app.apkFilePath)
                : _selectedItems.remove(widget.app.apkFilePath);
            print(_selectedItems.selectedItems);
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

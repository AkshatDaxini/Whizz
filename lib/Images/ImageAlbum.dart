import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:whizz/GlobalVariables.dart';
import './Recent.dart';

class ImageAlbum extends StatefulWidget {
  @override
  _ImageAlbumState createState() => _ImageAlbumState();
}

class _ImageAlbumState extends State<ImageAlbum> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: imageAlbumList.length,
      itemBuilder: (context, index) {
        return AlbumListTile(album: imageAlbumList[index]);
      },
    );
  }
}

class AlbumListTile extends StatefulWidget {
  final album;
  AlbumListTile({@required this.album});
  @override
  _AlbumListTileState createState() => _AlbumListTileState();
}

class _AlbumListTileState extends State<AlbumListTile> {
  bool isSelected = false;
  bool isVisible = false;
  List<AssetEntity> imageList = [];

  getAlbumImages() async {
    List<AssetEntity> imgList = await widget.album.assetList;
    setState(() {
      imageList = imgList;
    });
  }

  @override
  void initState() {
    super.initState();
    getAlbumImages();
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: Container(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: isVisible
                ? Icon(Icons.keyboard_arrow_down)
                : Icon(Icons.keyboard_arrow_right),
            title: Text(widget.album.name),
            subtitle: Text(imageList.length.toString()),
            // trailing: buildMasterCheckBox(),
          ),
        ),
      ),
      content: Visibility(
        maintainState: true,
        visible: isVisible,
        child: getAlbumImageGrid(imageList, isSelected),
      ),
    );
  }

  // buildMasterCheckBox() {
  //  return Checkbox(
  //     value: isSelected,
  //     onChanged: (bool value) {
  //       setState(() {
  //         isSelected =!isSelected;
  //       });
  //     },
  //   );
  // }
}

Widget getAlbumImageGrid(var imageList, bool isSelected) {
  return Container(
    height: 500,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // A grid view with 3 items per row
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: imageList.length,
      itemBuilder: (_, index) {
        return AssetThumbnail(image: imageList[index]);
      },
    ),
  );
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../GlobalVariables.dart';
import '../Application_Intialization/Initialization.dart';

class Recent extends StatefulWidget {
  Recent({Key key}) : super(key: key);
  @override
  _RecentState createState() => _RecentState();
}

class _RecentState extends State<Recent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      child: Container(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // A grid view with 3 items per row
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: recentAlbum.length,
          itemBuilder: (_, index) {
            // print("length" + assets.length.toString());
            return AssetThumbnail(image: recentAlbum[index]);
          },
        ),
      ),
      onRefresh: _pullRefresh,
    );
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 3));
    fetchImages();
    setState(() {});
  }
}

class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    Key key,
    @required this.image,
  }) : super(key: key);

  final AssetEntity image;

  @override
  _AssetThumbnailState createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail>
    with AutomaticKeepAliveClientMixin {
  bool _isSelected = false;
  Uint8List imgThumb;
  File imgFile;
  getImg() async {
    imgFile = await widget.image.file;
    imgThumb = await widget.image.thumbData;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getImg();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _selectedItems = Provider.of<SelectedItems>(context, listen: true);
    // String path = widget.image.relativePath + widget.image.title;
    if(_selectedItems.isEmpty) {
      _isSelected = false;
    }

    if (imgThumb == null) return Container();
    return InkWell(
      onTap: () {
        if (widget.image.type == AssetType.image) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageScreen(
                imageFile: imgFile,
                title: widget.image.title,
              ),
            ),
          );
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // Wrap the image in a Positioned.fill to fill the space
          Positioned.fill(
            child: Hero(
              tag: widget.image.title,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.memory(
                  imgThumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    "Something Went Wrong",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          // if (_isSelected)
          //   Container(
          //     color: Colors.black54,
          //   ),
          Checkbox(
              value: _isSelected,
               onChanged: (value) {
                _isSelected = !_isSelected;
                _isSelected
                    ? _selectedItems.add(imgFile.path)
                    : _selectedItems.remove(imgFile.path);
                print(_selectedItems.selectedItems);
                setState(() {});
              })
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key key,
    @required this.imageFile,
    @required this.title,
  }) : super(key: key);

  final File imageFile;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Hero(
          tag: title,
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}

// class CreateCheckbox extends StatefulWidget {
//   bool isSelected;
//   String path;

//   CreateCheckbox({this.path, this.isSelected});

//   @override
//   _CreateCheckboxState createState() => _CreateCheckboxState();
// }

// class _CreateCheckboxState extends State<CreateCheckbox>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     // super.build(context);
//     return Checkbox(
//       onChanged: (bool value) {
//         setState(() {
//           widget.isSelected = !widget.isSelected;
//           if (selectedItems.contains(widget.path)) {
//             selectedItems.remove(widget.path);
//           } else {
//             selectedItems.add(widget.path);
//           }
//           print(selectedItems);
//         });
//       },
//       value: widget.isSelected,
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

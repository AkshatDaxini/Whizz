import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:filesize/filesize.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';

import './GlobalVariables.dart';
import './Application_Intialization/Initialization.dart';

class Videos extends StatefulWidget {
  Videos({Key key}) : super(key: key);

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      child: Container(
        child: ListView.separated(
          separatorBuilder: (_, i) => Divider(),
          itemCount: videoAlbum.length,
          itemBuilder: (_, index) {
            return AssetThumbnail(video: videoAlbum[index]);
          },
        ),
      ),
      onRefresh: _pullRefresh,
    );
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    fetchVideos();
    setState(() {});
  }
}

class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    Key key,
    @required this.video,
  }) : super(key: key);

  final AssetEntity video;

  @override
  _AssetThumbnailState createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> with AutomaticKeepAliveClientMixin {
  bool _isSelected = false;
  var vidSize = "Unkown Size";
  var file;
  Future _getVidSize() async {
    file = await widget.video.file;
    var size = file.lengthSync();
    var vdSize = filesize(size);
    vidSize = vdSize;
  }

  @override
  void initState() {
    super.initState();
    _getVidSize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _selectedItems = Provider.of<SelectedItems>(context, listen: true);
    if(_selectedItems.isEmpty) {
      _isSelected = false;
    }
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List>(
      future: widget.video.thumbData,
      builder: (_, snapshot) {
        final videoThumb = snapshot.data;

        // If we have no data, display a spinner
        // if (bytes == null) return Center(child: CircularProgressIndicator());
        return ListTile(
          leading: InkWell(
            onTap: () async {
              var result = await OpenFile.open(file.path);
              print(result);
            },
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                videoThumb == null
                    ? Container(
                        height: MediaQuery.of(context).size.height * .15,
                        width: MediaQuery.of(context).size.height * .15,
                      )
                    : Image.memory(
                        videoThumb,
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * .15,
                        width: MediaQuery.of(context).size.height * .15,
                      ),
                Text(
                  widget.video.videoDuration.toString().replaceRange(7, 14, " "),
                  style: TextStyle(
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          title: Text(widget.video.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false),
          subtitle: Text(
            vidSize,
            style: TextStyle(fontSize: 12),
          ),
          trailing: _isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                )
              : null,
          selected: _isSelected,
          onTap: () {
            setState(() {
              _isSelected = !_isSelected;
              _isSelected ? _selectedItems.add(file.path) : _selectedItems.remove(file.path);
              print(_selectedItems.selectedItems);
            });
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

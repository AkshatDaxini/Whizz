import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/SongTile.dart';
import '../model/song.dart';
import '../model/album.dart';
import '../../GlobalVariables.dart';

class AudioAlbum extends StatefulWidget {
  AudioAlbum({Key key}) : super(key: key);

  @override
  _AudioAlbumState createState() => _AudioAlbumState();
}

class _AudioAlbumState extends State<AudioAlbum>
    with AutomaticKeepAliveClientMixin {
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: albumList == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: albumList.length,
              itemBuilder: (context, i) {
                Album album = albumList[i];
                return AlbumWidget(album: album);
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AlbumWidget extends StatefulWidget {
  final Album album;

  AlbumWidget({@required this.album});

  @override
  _AlbumWidgetState createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isDropdown = false;
  List<Song> _songList = [];

  getData() async {
    _songList = await Album().getAlbumSongs(widget.album.albumId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final _selectedItems = Provider.of<SelectedItems>(context, listen: false);
    super.build(context);
    if (_songList == null)
      return Container();
    else
      return Column(
        children: [
          InkWell(
            child: Container(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _isDropdown
                      ? Icon(Icons.keyboard_arrow_down)
                      : Icon(Icons.keyboard_arrow_right),
                  Expanded(
                    child: Text(
                      widget.album.title +
                          "(" +
                          _songList.length.toString() +
                          ")",
                      style: TextStyle(
                        color: widget.album.isSelected
                            ? isSelected_color
                            : default_font_color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: widget.album.isSelected,
                    onChanged: (value) {
                      setState(() {
                        widget.album.isSelected = !widget.album.isSelected;
                        _songList.forEach((song) {
                          song.isSelected = widget.album.isSelected;
                          if (widget.album.isSelected) {
                            if (!_selectedItems.selectedItems
                                .contains(song.filePath)) {
                              _selectedItems.add(song.filePath);
                            }
                          } else {
                            _selectedItems.remove(song.filePath);
                          }
                        });
                      });
                    },
                  )
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _isDropdown = !_isDropdown;
              });
            },
          ),
          Visibility(
            maintainState: true,
            visible: _isDropdown,
            child: getDropdown(_isDropdown),
          ),
          Divider(),
        ],
      );
  }

  Widget getDropdown(bool dropdown) {
    if (dropdown) {
      return Container(
        padding: EdgeInsets.all(5),
        child: ListView.separated(
          addAutomaticKeepAlives: true,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (_, i) => Divider(),
          itemCount: _songList.length,
          itemBuilder: (_, index) {
            Song song = _songList[index];
            print("Album:" + widget.album.isSelected.toString());
            return SongTile(
                song: song,
                onParentClick: (state) {
                  setState(() {
                    if (state == false) {
                      widget.album.isSelected = false;
                    } else {
                      widget.album.isSelected = _songList.every((song) => song.isSelected);
                    }
                  });
                },
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';

import '../model/song.dart';
import '../widgets/SongTile.dart';
import '../../GlobalVariables.dart';

class Music extends StatefulWidget {
  Music({Key key}) : super(key: key);

  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: songList == null
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              separatorBuilder: (_, index) {
                return Divider();
              },
              itemCount: songList.length,
              itemBuilder: (context, i) {
                Song song = songList[i];
                return SongTile(
                  song: song,
                );
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

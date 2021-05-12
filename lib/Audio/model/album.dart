import 'package:flutter_audio_query/flutter_audio_query.dart';

import './song.dart';

class Album {
  final String albumId;
  final String songCount;
  final String title;
  final String albumArt;
  bool isSelected = false;

  Album({
    this.albumId,
    this.songCount,
    this.title,
    this.albumArt,
  });

  List<Album> albumInfoToAlbum(List<AlbumInfo> albumInfo) {
    List<Album> albumList = [];
    for (var a in albumInfo) {
      Album _album = Album(
        albumArt: a.albumArt,
        albumId: a.id,
        songCount: a.numberOfSongs,
        title: a.title,
      );
      albumList.add(_album);
    }
    return albumList;
  }

  Future getAlbumSongs(String id) async {
    final songInfo = await FlutterAudioQuery().getSongsFromAlbum(albumId: id);
    List<Song> songList = Song().songInfoToSong(songInfo);
    return songList;
  }

  Future getDeviceAlbums() async {
    final _data = await FlutterAudioQuery().getAlbums();
    List<Album> albumList = albumInfoToAlbum(_data);
    return albumList;
  }
}

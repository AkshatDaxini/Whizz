import 'dart:io';

import 'package:flutter_audio_query/flutter_audio_query.dart';

class Song {
  final String title;
  final String duration;
  final String filePath;
  final String fileSize;
  final String albumArtwork;
  final String albumId;
  final String displayName;
  final String album;
  final File file;
  bool isSelected = false;

  Song({
    this.title,
    this.duration,
    this.filePath,
    this.fileSize,
    this.albumArtwork,
    this.albumId,
    this.displayName,
    this.album,
    this.file,
  });

  List<Song> songInfoToSong(List<SongInfo> songInfo) {
    List<Song> songList = [];
    for (var s in songInfo) {
      if (s.duration == null) continue;
      Song _song = Song(
        albumArtwork: s.albumArtwork,
        albumId: s.albumId,
        duration: s.duration,
        filePath: s.filePath,
        fileSize: s.fileSize,
        title: s.title,
        displayName: s.displayName,
        album: s.album,
        file: File(s.filePath),
      );
      songList.add(_song);
    }
    if (songList.isNotEmpty)
      songList.removeWhere((item) => !item.displayName.contains(".mp3"));
    return songList;
  }

  Future getDeviceSongs() async {
    final _data =
        await FlutterAudioQuery().getSongs(sortType: SongSortType.DISPLAY_NAME);
    List<Song> songList = songInfoToSong(_data);
    return songList;
  }
}

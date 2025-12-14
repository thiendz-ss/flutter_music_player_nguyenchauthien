import 'dart:io';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final Duration? duration;
  final int? fileSize;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    this.duration,
    this.fileSize,
  });

  factory SongModel.fromFile(File file) {
    final fileName = file.path.split('/').last;

    return SongModel(
      id: file.path,
      title: _extractTitle(fileName),
      artist: 'Unknown Artist',
      filePath: file.path,
      fileSize: file.lengthSync(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'fileSize': fileSize,
    };
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      filePath: json['filePath'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      fileSize: json['fileSize'],
    );
  }

  static String _extractTitle(String fileName) {
    if (fileName.contains('.')) {
      return fileName.substring(0, fileName.lastIndexOf('.'));
    }
    return fileName;
  }
}

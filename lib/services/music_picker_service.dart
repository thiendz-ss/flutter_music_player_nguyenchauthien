import 'dart:io';

import 'package:file_picker/file_picker.dart';
import '../models/song_model.dart';

class MusicPickerService {
  Future<List<SongModel>> pickSongs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
      allowMultiple: true,
    );

    if (result == null) {
      return [];
    }

    final files = result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();

    return files.map((file) => SongModel.fromFile(file)).toList();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _songPathKey = 'last_song_path';
  static const _isPlayingKey = 'is_playing';

  Future<void> saveLastSong(String path, bool isPlaying) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_songPathKey, path);
    await prefs.setBool(_isPlayingKey, isPlaying);
  }

  Future<Map<String, dynamic>?> getLastSong() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_songPathKey);
    if (path == null) return null;

    return {
      'path': path,
      'isPlaying': prefs.getBool(_isPlayingKey) ?? false,
    };
  }
}

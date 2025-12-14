import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService() {
    _initBackgroundAudio();
  }

  AudioPlayer get player => _player;

  Future<void> _initBackgroundAudio() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration.music(),
    );
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;

  Future<void> playFromFile(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      throw Exception('Cannot play audio: $e');
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatOff() async {
    await _player.setLoopMode(LoopMode.off);
  }

  Future<void> setRepeatOne() async {
    await _player.setLoopMode(LoopMode.one);
  }

  Future<void> setRepeatAll() async {
    await _player.setLoopMode(LoopMode.all);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

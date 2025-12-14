import 'package:flutter/material.dart';
import 'services/permission_service.dart';
import 'services/music_picker_service.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'models/song_model.dart';
import 'widgets/mini_player.dart';
import 'screens/now_playing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final PermissionService _permissionService = PermissionService();
  final MusicPickerService _musicPickerService = MusicPickerService();
  final StorageService _storageService = StorageService();

  List<SongModel> _songs = [];
  SongModel? _currentSong;
  bool _isPlaying = false;

  bool _isShuffle = false;
  int _repeatMode = 0; // 0: off, 1: all, 2: one
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _restoreLastSong();
  }

  Future<void> _restoreLastSong() async {
    final data = await _storageService.getLastSong();
    if (data == null) return;

    final path = data['path'] as String;
    final shouldPlay = data['isPlaying'] as bool;

    await _audioService.playFromFile(path);
    if (!shouldPlay) {
      await _audioService.pause();
    }

    _isPlaying = shouldPlay;
    setState(() {});
  }

  Future<void> _pickSongs() async {
    final granted = await _permissionService.requestAudioPermission();
    if (!granted) return;

    final songs = await _musicPickerService.pickSongs();
    if (songs.isEmpty) return;

    _songs = songs;
    _currentIndex = 0;
    _currentSong = songs.first;
    _isPlaying = true;

    await _audioService.playFromFile(_currentSong!.filePath);
    await _storageService.saveLastSong(
      _currentSong!.filePath,
      _isPlaying,
    );

    setState(() {});
  }

  Future<void> _playOrPause(SongModel song) async {
    final index = _songs.indexOf(song);
    if (index == -1) return;

    if (_currentSong?.filePath == song.filePath) {
      if (_isPlaying) {
        await _audioService.pause();
        _isPlaying = false;
      } else {
        await _audioService.play();
        _isPlaying = true;
      }
    } else {
      _currentIndex = index;
      _currentSong = song;
      _isPlaying = true;
      await _audioService.playFromFile(song.filePath);
    }

    await _storageService.saveLastSong(
      _currentSong!.filePath,
      _isPlaying,
    );

    setState(() {});
  }


  void _toggleShuffle() async {
    _isShuffle = !_isShuffle;
    await _audioService.setShuffle(_isShuffle);
    setState(() {});
  }

  void _toggleRepeat() async {
    _repeatMode = (_repeatMode + 1) % 3;

    if (_repeatMode == 0) {
      await _audioService.setRepeatOff();
    } else if (_repeatMode == 1) {
      await _audioService.setRepeatAll();
    } else {
      await _audioService.setRepeatOne();
    }

    setState(() {});
  }

  void _playNext() async {
    if (_songs.isEmpty) return;

    if (_isShuffle) {
      _currentIndex =
          DateTime.now().millisecondsSinceEpoch % _songs.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _songs.length;
    }

    _currentSong = _songs[_currentIndex];
    _isPlaying = true;

    await _audioService.playFromFile(_currentSong!.filePath);
    await _storageService.saveLastSong(
      _currentSong!.filePath,
      _isPlaying,
    );

    setState(() {});
  }

  void _playPrevious() async {
    if (_songs.isEmpty) return;

    _currentIndex =
        (_currentIndex - 1 + _songs.length) % _songs.length;

    _currentSong = _songs[_currentIndex];
    _isPlaying = true;

    await _audioService.playFromFile(_currentSong!.filePath);
    await _storageService.saveLastSong(
      _currentSong!.filePath,
      _isPlaying,
    );

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Music Player'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickSongs,
        child: const Icon(Icons.music_note),
      ),

      bottomNavigationBar: _currentSong == null
          ? null
          : GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NowPlayingScreen(
                song: _currentSong!,
                audioService: _audioService,
                isPlaying: _isPlaying,
                isShuffle: _isShuffle,
                repeatMode: _repeatMode,
                onPlayPause: () =>
                    _playOrPause(_currentSong!),
                onNext: _playNext,
                onPrevious: _playPrevious,
                onShuffle: _toggleShuffle,
                onRepeat: _toggleRepeat,
              ),
            ),
          );
        },
        child: MiniPlayer(
          song: _currentSong!,
          isPlaying: _isPlaying,
          onPlayPause: () =>
              _playOrPause(_currentSong!),
        ),
      ),


      body: _songs.isEmpty
          ? const Center(
        child: Text(
          'No songs selected',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          final isCurrent =
              _currentSong?.filePath == song.filePath;

          return ListTile(
            leading: Icon(
              isCurrent && _isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
              color: Colors.green,
              size: 32,
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _playOrPause(song),
          );
        },
      ),
    );
  }
}

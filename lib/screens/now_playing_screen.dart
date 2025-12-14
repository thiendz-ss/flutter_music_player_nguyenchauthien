import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';

class NowPlayingScreen extends StatelessWidget {
  final SongModel song;
  final AudioPlayerService audioService;

  final bool isPlaying;
  final bool isShuffle;
  final int repeatMode;

  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;

  const NowPlayingScreen({
    super.key,
    required this.song,
    required this.audioService,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onRepeat,
  });

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Spacer(),

          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              size: 120,
              color: Colors.white54,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          StreamBuilder<Duration?>(
            stream: audioService.durationStream,
            builder: (context, durSnap) {
              final total = durSnap.data ?? Duration.zero;

              return StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? Duration.zero;

                  final double maxMs =
                  total.inMilliseconds.clamp(1, double.infinity).toDouble();
                  final double valMs =
                  pos.inMilliseconds.clamp(0, maxMs).toDouble();

                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        max: maxMs,
                        value: valMs,
                        onChanged: (v) {
                          audioService.seek(
                            Duration(milliseconds: v.toInt()),
                          );
                        },
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(pos),
                              style:
                              const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              _format(total),
                              style:
                              const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: isShuffle ? Colors.green : Colors.grey,
                ),
                onPressed: onShuffle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous,
                    color: Colors.white, size: 36),
                onPressed: onPrevious,
              ),
              IconButton(
                iconSize: 72,
                color: Colors.green,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                ),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next,
                    color: Colors.white, size: 36),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(
                  repeatMode == 2
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: repeatMode == 0
                      ? Colors.grey
                      : Colors.green,
                ),
                onPressed: onRepeat,
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

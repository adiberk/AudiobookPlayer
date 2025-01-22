import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onForward;
  final VoidCallback onRewind;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onForward,
    required this.onRewind,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seek bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                onSeek(Duration(seconds: value.toInt()));
              },
            ),
          ),

          // Duration labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DurationFormatter.format(position),
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  DurationFormatter.format(duration),
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_30),
                iconSize: 40,
                onPressed: onRewind,
              ),
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 64,
                ),
                iconSize: 64,
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.forward_30),
                iconSize: 40,
                onPressed: onForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

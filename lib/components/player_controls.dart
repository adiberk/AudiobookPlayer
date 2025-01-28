import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';
import '../utils/duration_formatter.dart';

class PlayerControls extends ConsumerWidget {
  final Audiobook audiobook;
  final Chapter currentChapter;

  const PlayerControls({
    Key? key,
    required this.audiobook,
    required this.currentChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final position = ref.watch(currentPositionProvider).value ?? Duration.zero;
    final isPlaying = ref.watch(audioPlayingStateProvider);
    final duration = ref.watch(durationProvider).value ?? Duration.zero;

    Duration chapterPosition;
    Duration chapterDuration;

    if (audiobook.isJoinedVolume) {
      // For joined volumes, we want the position relative to the current chapter
      chapterPosition = position;
      chapterDuration = currentChapter.end - currentChapter.start;
    } else {
      // For single files, calculate relative to chapter start
      chapterPosition = position - currentChapter.start;
      chapterDuration = currentChapter.end - currentChapter.start;
    }

    // Ensure position is within bounds
    chapterPosition = Duration(
        milliseconds: chapterPosition.inMilliseconds
            .clamp(0, chapterDuration.inMilliseconds));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DurationFormatter.format(chapterPosition)),
              Text(DurationFormatter.format(chapterDuration)),
            ],
          ),
        ),
        Slider(
          value: chapterPosition.inSeconds.toDouble(),
          min: 0,
          max: chapterDuration.inSeconds.toDouble(),
          onChanged: (value) {
            if (audiobook.isJoinedVolume) {
              // For joined volumes, seek within the current chapter
              audioService.seek(Duration(seconds: value.toInt()));
            } else {
              audioService.seek(
                currentChapter.start + Duration(seconds: value.toInt()),
              );
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_30),
              onPressed: () => audioService.skipBackward(),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 48,
              ),
              onPressed: () {
                ref.read(audioPlayingStateProvider.notifier).togglePlayPause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_30),
              onPressed: () => audioService.skipForward(),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

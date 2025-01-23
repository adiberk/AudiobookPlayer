import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import '../services/audio_service.dart';
import '../services/chapter_manager.dart';
import '../utils/duration_formatter.dart';

class PlayerControls extends StatelessWidget {
  final AudioService audioService;
  final Audiobook audiobook;
  final Chapter currentChapter;

  const PlayerControls({
    Key? key,
    required this.audioService,
    required this.audiobook,
    required this.currentChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration>(
          stream: audioService.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            Duration chapterPosition;
            Duration chapterDuration;

            if (audiobook.isJoinedVolume) {
              // For joined volumes, we use the actual position from the current file
              chapterPosition = position;
              chapterDuration = currentChapter.end - currentChapter.start;
            } else {
              // For single files, we calculate relative to chapter start
              chapterPosition = position - currentChapter.start;
              chapterDuration = currentChapter.end - currentChapter.start;
            }

            // Ensure position is within bounds
            chapterPosition = Duration(
                milliseconds: chapterPosition.inMilliseconds
                    .clamp(0, chapterDuration.inMilliseconds));

            return Column(
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
                      audioService.seek(Duration(seconds: value.toInt()));
                    } else {
                      audioService.seek(
                        currentChapter.start + Duration(seconds: value.toInt()),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_30),
              onPressed: () => audioService.skipBackward(),
            ),
            StreamBuilder<PlayerState>(
              stream: audioService.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = audioService.isPlaying;
                return IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 48,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.play();
                    }
                  },
                );
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

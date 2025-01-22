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
            final chapterPosition = position - currentChapter.start;
            final chapterDuration = currentChapter.end - currentChapter.start;

            // Check if chapter has ended
            if (position >= currentChapter.end) {
              final currentIndex =
                  ChapterManager.getCurrentChapterIndex(audiobook, position);
              ChapterManager.handleChapterEnd(
                  audioService, audiobook, currentIndex);
            }

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
                  max: chapterDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    audioService.seek(
                      currentChapter.start + Duration(seconds: value.toInt()),
                    );
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

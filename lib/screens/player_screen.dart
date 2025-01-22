import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../components/chapter_list.dart';
import '../components/player_controls.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final Audiobook audiobook;
  final AudioService audioService;
  final VoidCallback onMinimize;

  const PlayerScreen({
    super.key,
    required this.audiobook,
    required this.audioService,
    required this.onMinimize,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.audiobook.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              widget.audiobook.author,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => ChapterList(
                              chapters: widget.audiobook.chapters,
                              onChapterSelected: (chapter) {
                                widget.audioService.seek(chapter.start);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Cover art
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: widget.audiobook.coverImage != null
                        ? Image.memory(widget.audiobook.coverImage!)
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.book, size: 100),
                          ),
                  ),
                ),

                // Player controls
                StreamBuilder<PlayerState>(
                  stream: widget.audioService.playerStateStream,
                  builder: (context, snapshot) {
                    return StreamBuilder<Duration>(
                      stream: widget.audioService.positionStream,
                      builder: (context, positionSnapshot) {
                        return PlayerControls(
                          isPlaying: widget.audioService.isPlaying,
                          position: positionSnapshot.data ?? Duration.zero,
                          duration: widget.audioService.duration,
                          onPlayPause: () {
                            if (widget.audioService.isPlaying) {
                              widget.audioService.pause();
                            } else {
                              widget.audioService.play();
                            }
                          },
                          onSeek: widget.audioService.seek,
                          onForward: widget.audioService.skipForward,
                          onRewind: widget.audioService.skipBackward,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';

class MiniPlayer extends ConsumerWidget {
  final Audiobook audiobook;
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.audiobook,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final isPlaying = ref.watch(audioPlayingStateProvider);
    final position = ref.watch(currentPositionProvider).value ?? Duration.zero;
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);

    final currentChapter = audiobook.isJoinedVolume
        ? audiobook.chapters[currentChapterIndex]
        : ref.watch(currentChapterProvider(position));

    return GestureDetector(
      onTap: onTap, // This should now just handle navigation
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (audiobook.coverImage != null)
              SizedBox(
                width: 60,
                height: 60,
                child: Image.memory(
                  audiobook.coverImage!,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audiobook.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${audiobook.author} • ${currentChapter.title}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_30),
                  onPressed: () => audioService.skipBackward(),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    ref
                        .read(audioPlayingStateProvider.notifier)
                        .togglePlayPause();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_30),
                  onPressed: () => audioService.skipForward(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

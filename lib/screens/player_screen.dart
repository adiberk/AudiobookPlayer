import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/chapter_list.dart';
import '../components/chapter_selection_dropdown.dart';
import '../components/player_controls.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const PlayerScreen({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isChaptersVisible = false;

  void _showChapterSelection(BuildContext context, Chapter currentChapter) {
    final audiobook = ref.read(currentAudiobookProvider);
    if (audiobook == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ChapterSelectionSheet(
        chapters: audiobook.chapters,
        currentChapter: currentChapter,
        onChapterSelected: (chapter) async {
          final audioService = ref.read(audioServiceProvider);
          final chapterIndex = audiobook.chapters.indexOf(chapter);

          if (audiobook.isJoinedVolume) {
            await audioService.seekToChapter(chapterIndex);
          } else {
            await audioService
                .seek(chapter.start + const Duration(milliseconds: 1));
          }

          ref.read(currentChapterIndexProvider.notifier).state = chapterIndex;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audiobook = ref.watch(currentAudiobookProvider);
    if (audiobook == null) return const SizedBox.shrink();

    // Listen to currentIndex changes for joined volumes
    ref.listen<int>(currentChapterIndexProvider, (_, int index) {
      if (audiobook.isJoinedVolume) {
        setState(() {
          // Trigger rebuild to update chapter display
        });
      }
    });

    return Dismissible(
      key: const Key('player_screen'),
      direction: DismissDirection.down,
      onDismissed: (_) => widget.onClose(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: widget.onClose,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  _isChaptersVisible = !_isChaptersVisible;
                });
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final position =
                ref.watch(currentPositionProvider).value ?? Duration.zero;
            final currentChapterIndex = ref.watch(currentChapterIndexProvider);
            final currentChapter = audiobook.isJoinedVolume
                ? audiobook.chapters[currentChapterIndex]
                : ref.watch(currentChapterProvider(position));

            return Column(
              children: [
                if (_isChaptersVisible)
                  Expanded(
                    child: ChaptersList(
                      chapters: audiobook.chapters,
                      currentChapter: currentChapter,
                    ),
                  ),
                if (!_isChaptersVisible)
                  _buildMainContent(context, audiobook, currentChapter),
                PlayerControls(
                  audiobook: audiobook,
                  currentChapter: currentChapter,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, Audiobook audiobook, Chapter currentChapter) {
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (audiobook.coverImage != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.memory(
                  audiobook.coverImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              audiobook.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            audiobook.author,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: currentChapterIndex > 0
                    ? () {
                        final audioService = ref.read(audioServiceProvider);
                        if (audiobook.isJoinedVolume) {
                          audioService.skipToPrevious();
                        } else {
                          final previousChapter =
                              audiobook.chapters[currentChapterIndex - 1];
                          audioService.seek(previousChapter.start +
                              const Duration(milliseconds: 1));
                        }
                        ref.read(currentChapterIndexProvider.notifier).state =
                            currentChapterIndex - 1;
                      }
                    : null,
              ),
              GestureDetector(
                onTap: () => _showChapterSelection(context, currentChapter),
                child: Row(
                  children: [
                    Text(
                      currentChapter.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: currentChapterIndex < audiobook.chapters.length - 1
                    ? () {
                        final audioService = ref.read(audioServiceProvider);
                        if (audiobook.isJoinedVolume) {
                          audioService.skipToNext();
                        } else {
                          final nextChapter =
                              audiobook.chapters[currentChapterIndex + 1];
                          audioService.seek(nextChapter.start +
                              const Duration(milliseconds: 1));
                        }
                        ref.read(currentChapterIndexProvider.notifier).state =
                            currentChapterIndex + 1;
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

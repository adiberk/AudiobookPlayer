import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../services/audio_service.dart';
import '../services/chapter_manager.dart';
import '../components/player_controls.dart';
import '../utils/duration_formatter.dart';

class PlayerScreen extends StatefulWidget {
  final Audiobook audiobook;
  final AudioService audioService;
  final VoidCallback onClose;

  const PlayerScreen({
    Key? key,
    required this.audiobook,
    required this.audioService,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isChaptersVisible = false;

  @override
  void initState() {
    super.initState();
    _initAudiobook();
  }

  Future<void> _initAudiobook() async {
    await widget.audioService.setAudiobook(widget.audiobook);
  }

  void _showChapterSelection(BuildContext context, Chapter currentChapter) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChapterSelectionSheet(
        chapters: widget.audiobook.chapters,
        currentChapter: currentChapter,
        onChapterSelected: (chapter) {
          widget.audioService.seek(chapter.start);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        body: StreamBuilder<Duration>(
          stream: widget.audioService.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final currentChapter =
                ChapterManager.getCurrentChapter(widget.audiobook, position);
            final currentIndex = ChapterManager.getCurrentChapterIndex(
                widget.audiobook, position);

            return Column(
              children: [
                if (_isChaptersVisible)
                  Expanded(
                    child: ChaptersList(
                      chapters: widget.audiobook.chapters,
                      audioService: widget.audioService,
                      currentChapter: currentChapter,
                    ),
                  ),
                if (!_isChaptersVisible)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.audiobook.coverImage != null)
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.memory(
                                widget.audiobook.coverImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            widget.audiobook.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          widget.audiobook.author,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: currentIndex > 0
                                  ? () => ChapterManager.skipToPreviousChapter(
                                      widget.audioService,
                                      widget.audiobook,
                                      position)
                                  : null,
                            ),
                            GestureDetector(
                              onTap: () => _showChapterSelection(
                                  context, currentChapter),
                              child: Row(
                                children: [
                                  Text(
                                    currentChapter.title,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: currentIndex <
                                      widget.audiobook.chapters.length - 1
                                  ? () => ChapterManager.skipToNextChapter(
                                      widget.audioService,
                                      widget.audiobook,
                                      position)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                PlayerControls(
                  audioService: widget.audioService,
                  audiobook: widget.audiobook,
                  currentChapter: currentChapter,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChapterSelectionSheet extends StatelessWidget {
  final List<Chapter> chapters;
  final Chapter currentChapter;
  final Function(Chapter) onChapterSelected;

  const ChapterSelectionSheet({
    Key? key,
    required this.chapters,
    required this.currentChapter,
    required this.onChapterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text(chapter.title),
                  subtitle: Text(
                    DurationFormatter.format(chapter.end - chapter.start),
                  ),
                  selected: chapter.title == currentChapter.title,
                  leading: Text('${index + 1}'),
                  onTap: () => onChapterSelected(chapter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChaptersList extends StatelessWidget {
  final List<Chapter> chapters;
  final AudioService audioService;
  final Chapter currentChapter;

  const ChaptersList({
    Key? key,
    required this.chapters,
    required this.audioService,
    required this.currentChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          title: Text(chapter.title),
          subtitle: Text(
            DurationFormatter.format(chapter.end - chapter.start),
          ),
          selected: chapter.title == currentChapter.title,
          leading: Text('${index + 1}'),
          onTap: () async {
            await audioService.seek(chapter.start);
          },
        );
      },
    );
  }
}

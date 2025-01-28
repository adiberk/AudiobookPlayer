import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../components/mini_player.dart';
import '../providers/providers.dart';
import 'player_screen.dart';
import '../utils/duration_formatter.dart';

class FolderContentsScreen extends ConsumerStatefulWidget {
  final Audiobook folderBook;

  const FolderContentsScreen({
    Key? key,
    required this.folderBook,
  }) : super(key: key);

  @override
  ConsumerState<FolderContentsScreen> createState() =>
      _FolderContentsScreenState();
}

class _FolderContentsScreenState extends ConsumerState<FolderContentsScreen> {
  void _showPlayerScreen(Audiobook book) async {
    // Only stop and reinitialize if it's a different book
    if (ref.read(currentAudiobookProvider)?.id != book.id) {
      final audioService = ref.read(audioServiceProvider);
      await audioService.pause();
      ref.read(currentAudiobookProvider.notifier).state = book;
      await audioService.setAudiobook(book);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerScreen(
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBook = ref.watch(currentAudiobookProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderBook.title),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: currentBook != null ? 60 : 0),
            itemCount: widget.folderBook.chapters.length,
            itemBuilder: (context, index) {
              final chapter = widget.folderBook.chapters[index];
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: widget.folderBook.coverImage != null
                      ? Image.memory(
                          widget.folderBook.coverImage!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.audio_file),
                ),
                title: Text(chapter.title),
                subtitle:
                    Text(DurationFormatter.format(chapter.end - chapter.start)),
                onTap: () {
                  final singleFileBook = Audiobook(
                    title: chapter.title,
                    author: widget.folderBook.author,
                    duration:
                        DurationFormatter.format(chapter.end - chapter.start),
                    path: chapter.filePath!,
                    coverImage: widget.folderBook.coverImage,
                    chapters: [
                      Chapter(
                        title: chapter.title,
                        start: Duration.zero,
                        end: chapter.end - chapter.start,
                        filePath: chapter.filePath,
                      )
                    ],
                  );

                  _showPlayerScreen(singleFileBook);
                },
              );
            },
          ),
          if (currentBook != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                audiobook: currentBook,
                onTap: () => _showPlayerScreen(currentBook),
              ),
            ),
        ],
      ),
    );
  }
}

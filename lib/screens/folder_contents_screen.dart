import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../services/audio_service.dart';
import '../services/library_manager.dart';
import '../components/mini_player.dart';
import 'player_screen.dart';
import '../utils/duration_formatter.dart';

class FolderContentsScreen extends StatefulWidget {
  final Audiobook folderBook;
  final AudioService audioService;
  final LibraryManager libraryManager;

  const FolderContentsScreen({
    Key? key,
    required this.folderBook,
    required this.audioService,
    required this.libraryManager,
  }) : super(key: key);

  @override
  State<FolderContentsScreen> createState() => _FolderContentsScreenState();
}

class _FolderContentsScreenState extends State<FolderContentsScreen> {
  Audiobook? _currentPlayingBook;
  bool _isPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    // Check if there's currently playing audio
    _checkCurrentlyPlaying();
  }

  void _checkCurrentlyPlaying() {
    if (widget.audioService.isPlaying) {
      setState(() {
        _isPlayerVisible = true;
        // Get the currently playing book from the audio service
        _currentPlayingBook = widget.audioService.currentBook;
      });
    }
  }

  void _showPlayerScreen(Audiobook book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerScreen(
        audiobook: book,
        audioService: widget.audioService,
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _isPlayerVisible = true;
            _currentPlayingBook = book;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderBook.title),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: _isPlayerVisible ? 60 : 0),
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

                  setState(() {
                    _currentPlayingBook = singleFileBook;
                    _isPlayerVisible = false;
                  });

                  _showPlayerScreen(singleFileBook);
                },
              );
            },
          ),
          if (_isPlayerVisible && _currentPlayingBook != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                audiobook: _currentPlayingBook!,
                audioService: widget.audioService,
                onTap: () => _showPlayerScreen(_currentPlayingBook!),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height:
            kBottomNavigationBarHeight, // Standard height for a BottomNavigationBar
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context)
                .colorScheme
                .surface, // Fallback to theme surface color
      ),
    );
  }
}

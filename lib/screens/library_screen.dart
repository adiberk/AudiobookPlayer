import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/audiobook_tile.dart';
import '../components/mini_player.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';
import 'player_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isSelectionMode = false;
  Set<String> _selectedBooks = {};
  String _sortOption = 'title';

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedBooks.clear();
      }
    });
  }

  void _toggleBookSelection(String bookId) {
    setState(() {
      if (_selectedBooks.contains(bookId)) {
        _selectedBooks.remove(bookId);
      } else {
        _selectedBooks.add(bookId);
      }
    });
  }

  void _showPlayerScreen(BuildContext context, Audiobook audiobook) async {
    // Don't stop playback, just set the audiobook if it's different
    if (ref.read(currentAudiobookProvider) != audiobook) {
      ref.read(currentAudiobookProvider.notifier).state = audiobook;
      final audioService = ref.read(audioServiceProvider);
      await audioService.setAudiobook(audiobook);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerScreen(
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Title'),
                leading: Radio<String>(
                  value: 'title',
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() => _sortOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Author'),
                leading: Radio<String>(
                  value: 'author',
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() => _sortOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Duration'),
                leading: Radio<String>(
                  value: 'duration',
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() => _sortOption = value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Audiobook> _sortAudiobooks(List<Audiobook> audiobooks) {
    switch (_sortOption) {
      case 'title':
        audiobooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        audiobooks.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'duration':
        audiobooks.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }
    return audiobooks;
  }

  @override
  Widget build(BuildContext context) {
    final audiobooks = ref.watch(audiobooksProvider);
    final currentBook = ref.watch(currentAudiobookProvider);
    final audioService = ref.watch(audioServiceProvider);

    final sortedAudiobooks = _sortAudiobooks([...audiobooks]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              onSelected: (String choice) async {
                if (choice == 'files') {
                  final importService = ref.read(importServiceProvider);
                  final books = await importService.importFiles();
                  for (final book in books) {
                    await ref
                        .read(audiobooksProvider.notifier)
                        .addAudiobook(book);
                  }
                } else if (choice == 'folder') {
                  final importService = ref.read(importServiceProvider);
                  final book = await importService.importFolder();
                  if (book != null) {
                    await ref
                        .read(audiobooksProvider.notifier)
                        .addAudiobook(book);
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'files',
                    child: Text('Import Files'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'folder',
                    child: Text('Import Folder'),
                  ),
                ];
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedBooks.isEmpty
                  ? null
                  : () => ref
                      .read(audiobooksProvider.notifier)
                      .deleteAudiobooks(_selectedBooks),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                      onPressed: _showSortOptions,
                    ),
                    TextButton(
                      onPressed: _toggleSelectionMode,
                      child: Text(_isSelectionMode ? 'Cancel' : 'Select'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sortedAudiobooks.isEmpty
                    ? const Center(
                        child: Text(
                            'No audiobooks found. Import some books to get started!'),
                      )
                    : ListView.builder(
                        itemCount: sortedAudiobooks.length,
                        padding: EdgeInsets.only(
                            bottom: currentBook != null ? 60 : 0),
                        itemBuilder: (context, index) {
                          final audiobook = sortedAudiobooks[index];
                          return AudiobookTile(
                            audiobook: audiobook,
                            isSelected: _selectedBooks.contains(audiobook.id),
                            selectionMode: _isSelectionMode,
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleBookSelection(audiobook.id);
                              } else if (!(audiobook.isFolder &&
                                  !audiobook.isJoinedVolume)) {
                                _showPlayerScreen(context, audiobook);
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _toggleSelectionMode();
                                _toggleBookSelection(audiobook.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          if (currentBook != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                audiobook: currentBook,
                onTap: () => _showPlayerScreen(context, currentBook),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../components/audiobook_tile.dart';
import '../components/mini_player.dart';
import '../screens/player_screen.dart';
import '../services/library_manager.dart';
import '../services/audio_service.dart';

class LibraryScreen extends StatefulWidget {
  final LibraryManager libraryManager;

  const LibraryScreen({
    Key? key,
    required this.libraryManager,
  }) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Audiobook? _currentAudiobook;
  bool _isPlayerVisible = false;
  final AudioService _audioService = AudioService();
  bool _isSelectionMode = false;
  Set<String> _selectedBooks = {};
  String _sortOption = 'title'; // Default sort option

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

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

  Future<void> _deleteSelectedBooks() async {
    if (_selectedBooks.isNotEmpty) {
      final bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Selected Books'),
              content: Text(
                  'Are you sure you want to delete ${_selectedBooks.length} selected books?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirm) {
        await widget.libraryManager.deleteAudiobooks(_selectedBooks);
        _toggleSelectionMode();
      }
    }
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

  void _showPlayerScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerScreen(
        audiobook: _currentAudiobook!,
        audioService: _audioService,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onSelected: (String choice) {
                if (choice == 'files') {
                  widget.libraryManager.importFiles();
                } else if (choice == 'folder') {
                  widget.libraryManager.importFolder();
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
              onPressed: _selectedBooks.isEmpty ? null : _deleteSelectedBooks,
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
                child: StreamBuilder<List<Audiobook>>(
                  stream: widget.libraryManager.audiobooksStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final audiobooks = _sortAudiobooks(snapshot.data!);

                    if (audiobooks.isEmpty) {
                      return const Center(
                        child: Text(
                            'No audiobooks found. Import some books to get started!'),
                      );
                    }

                    return ListView.builder(
                      itemCount: audiobooks.length,
                      itemBuilder: (context, index) {
                        final audiobook = audiobooks[index];
                        return AudiobookTile(
                          audiobook: audiobook,
                          isSelected: _selectedBooks.contains(audiobook.id),
                          selectionMode: _isSelectionMode,
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleBookSelection(audiobook.id);
                            } else {
                              setState(() {
                                _currentAudiobook = audiobook;
                                _isPlayerVisible = true;
                              });
                              _showPlayerScreen(context);
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
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isPlayerVisible && _currentAudiobook != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                audiobook: _currentAudiobook!,
                audioService: _audioService,
                onTap: () => _showPlayerScreen(context),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import '../services/file_service.dart';
import '../services/metadata_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../components/audiobook_list_item.dart';
import '../components/mini_player.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Audiobook> audiobooks = [];
  Audiobook? currentAudiobook;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _loadAudiobooks();
  }

  Future<void> _loadAudiobooks() async {
    final loadedBooks = await StorageService.loadAudiobooks();
    setState(() {
      audiobooks = loadedBooks;
    });
  }

  Future<void> _importAudiobook() async {
    String? filePath = await pickAudiobookFile();
    if (filePath != null) {
      final metadata = await MetadataService.extractMetadata(filePath);

      final audiobook = Audiobook(
        title: metadata['title'] ?? 'Unknown Title',
        author: metadata['author'] ?? 'Unknown Author',
        duration: metadata['duration']?['formatted'] ?? '0:00',
        path: filePath,
        coverImage: metadata['cover_photo'],
        chapters: List<Chapter>.from(metadata['chapters'] ?? []),
      );

      setState(() {
        audiobooks.add(audiobook);
      });

      await StorageService.saveAudiobooks(audiobooks);
    }
  }

  Future<void> _deleteAudiobook(Audiobook audiobook) async {
    setState(() {
      audiobooks.removeWhere((book) => book.id == audiobook.id);
      if (currentAudiobook?.id == audiobook.id) {
        currentAudiobook = null;
      }
    });
    await StorageService.saveAudiobooks(audiobooks);
  }

  void _showPlayerScreen(Audiobook audiobook) async {
    setState(() {
      currentAudiobook = audiobook;
    });
    await _audioService.setAudiobook(audiobook);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerScreen(
        audiobook: audiobook,
        audioService: _audioService,
        onMinimize: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _importAudiobook,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: audiobooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No audiobooks yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _importAudiobook,
                          icon: const Icon(Icons.add),
                          label: const Text('Import Audiobook'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: audiobooks.length,
                    itemBuilder: (context, index) {
                      final audiobook = audiobooks[index];
                      return AudiobookListItem(
                        audiobook: audiobook,
                        onDelete: _deleteAudiobook,
                        onTap: () => _showPlayerScreen(audiobook),
                      );
                    },
                  ),
          ),
          if (currentAudiobook != null)
            StreamBuilder<PlayerState>(
              stream: _audioService.playerStateStream,
              builder: (context, snapshot) {
                return MiniPlayer(
                  audiobook: currentAudiobook!,
                  isPlaying: _audioService.isPlaying,
                  onPlayPause: () {
                    if (_audioService.isPlaying) {
                      _audioService.pause();
                    } else {
                      _audioService.play();
                    }
                  },
                  onTap: () => _showPlayerScreen(currentAudiobook!),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

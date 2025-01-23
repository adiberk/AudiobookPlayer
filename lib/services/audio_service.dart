import 'package:audiobook_manager/services/storage_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import 'chapter_manager.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _player = AudioPlayer();
  final _storageService = StorageService();
  Audiobook? _currentBook;
  ConcatenatingAudioSource? _playlist;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Audiobook? get currentBook => _currentBook;
  int get currentIndex => _player.currentIndex ?? 0;

  Future<void> setAudiobook(Audiobook book) async {
    try {
      if (_currentBook?.id != book.id) {
        await _player.stop();
        _currentBook = book;

        if (book.isFolder && book.isJoinedVolume) {
          // Create a playlist for joined volumes
          _playlist = ConcatenatingAudioSource(
            children: book.chapters
                .map((chapter) => AudioSource.file(chapter.filePath!))
                .toList(),
          );
          await _player.setAudioSource(_playlist!);

          // Set initial chapter index
          if (book.currentChapterIndex > 0) {
            await _player.seek(Duration.zero, index: book.currentChapterIndex);
          }
        } else {
          // Single file or individual chapter
          _playlist = null;
          await _player.setFilePath(book.path);
        }

        // Seek to saved position if it exists
        if (book.currentPosition > Duration.zero) {
          await _player.seek(book.currentPosition);
        }
      }
    } catch (e) {
      print('Error setting audiobook: $e');
    }
  }

  // Add method to update current chapter index

  Future<void> updateCurrentChapter(int index) async {
    if (_currentBook != null) {
      _currentBook = _currentBook!.copyWith(currentChapterIndex: index);
      // You might want to persist this change
      await _storageService.updateAudiobook(_currentBook!);
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);

    // For single file audiobooks, update current chapter based on position
    if (_currentBook != null && !_currentBook!.isJoinedVolume) {
      final currentIndex =
          ChapterManager.getCurrentChapterIndex(_currentBook!, position);
      await updateCurrentChapter(currentIndex);
    }
  }

  Future<void> skipForward() async {
    final newPosition = _player.position + const Duration(seconds: 30);
    await _player.seek(newPosition);
  }

  Future<void> skipBackward() async {
    final newPosition = _player.position - const Duration(seconds: 30);
    await _player.seek(newPosition);
  }

  Future<void> skipToNext() async {
    if (_playlist != null && _player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    if (_playlist != null && _player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (_playlist != null &&
        chapterIndex >= 0 &&
        chapterIndex < _playlist!.length) {
      await _player.seek(Duration.zero, index: chapterIndex);

      // Update the current book's chapter index
      if (_currentBook != null) {
        _currentBook =
            _currentBook!.copyWith(currentChapterIndex: chapterIndex);
      }
    }
  }

  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  Future<void> dispose() async {
    await _player.dispose();
  }
}

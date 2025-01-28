import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initAudioPlayer();
  }

  final _player = AudioPlayer();
  final _storageService = StorageService();
  Audiobook? _currentBook;
  ConcatenatingAudioSource? _playlist;

  void _initAudioPlayer() {
    _player.playerStateStream.listen((state) {
      // Handle state changes if needed
    });

    _player.positionStream.listen((position) {
      // Update current position
      if (_currentBook != null) {
        _currentBook = _currentBook!.copyWith(currentPosition: position);
        _storageService.updateAudiobook(_currentBook!);
      }
    });
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Audiobook? get currentBook => _currentBook;
  int get currentIndex => _player.currentIndex ?? 0;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;

  Future<void> setAudiobook(Audiobook book) async {
    try {
      if (_currentBook?.id != book.id) {
        final wasPlaying = _player.playing;
        await _player.stop();
        _currentBook = book;

        if (book.isFolder && book.isJoinedVolume) {
          _playlist = ConcatenatingAudioSource(
            children: book.chapters
                .map((chapter) => AudioSource.file(chapter.filePath!))
                .toList(),
          );
          await _player.setAudioSource(_playlist!);
          if (book.currentChapterIndex > 0) {
            await _player.seek(Duration.zero, index: book.currentChapterIndex);
          }
        } else {
          _playlist = null;
          await _player.setFilePath(book.path);
        }

        if (book.currentPosition > Duration.zero) {
          await _player.seek(book.currentPosition);
        }

        // Restore playing state if it was playing
        if (wasPlaying) {
          await _player.play();
        }
      }
    } catch (e) {
      print('Error setting audiobook: $e');
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
    if (_currentBook?.isJoinedVolume == true) {
      if (_playlist != null &&
          chapterIndex >= 0 &&
          chapterIndex < _playlist!.length) {
        await _player.seek(Duration.zero, index: chapterIndex);
        if (_currentBook != null) {
          _currentBook =
              _currentBook!.copyWith(currentChapterIndex: chapterIndex);
          await _storageService.updateAudiobook(_currentBook!);
        }
      }
    }
  }

  Duration get duration {
    if (_currentBook?.isJoinedVolume == true) {
      final chapter = _currentBook!.chapters[currentIndex];
      return chapter.end - chapter.start;
    }
    return _player.duration ?? Duration.zero;
  }

  Stream<Duration> get durationStream {
    if (_currentBook?.isJoinedVolume == true) {
      return _player.currentIndexStream.map((index) {
        if (index != null && _currentBook != null) {
          final chapter = _currentBook!.chapters[index];
          return chapter.end - chapter.start;
        }
        return Duration.zero;
      });
    }
    return _player.durationStream.map((duration) => duration ?? Duration.zero);
  }

  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  Future<void> dispose() async {
    await _player.dispose();
  }
}

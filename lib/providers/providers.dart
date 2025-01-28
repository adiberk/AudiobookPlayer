import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import '../services/audio_service.dart';
import '../services/hive_storage_service.dart';
import '../services/import_service.dart';

// Services providers
final storageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

// Audiobooks state provider
final audiobooksProvider =
    StateNotifierProvider<AudiobooksNotifier, List<Audiobook>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AudiobooksNotifier(storageService);
});

// Current audiobook provider
final currentAudiobookProvider = StateProvider<Audiobook?>((ref) => null);

// Audio playing state provider
final audioPlayingStateProvider =
    StateNotifierProvider<AudioPlayingNotifier, bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioPlayingNotifier(audioService);
});

// Current position provider
final currentPositionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

// Duration provider
final durationProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});

// Player state provider
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playerStateStream;
});

// Current chapter provider
final currentChapterProvider =
    Provider.family<Chapter, Duration>((ref, position) {
  final currentBook = ref.watch(currentAudiobookProvider);
  if (currentBook == null) {
    throw Exception('No audiobook is currently playing');
  }

  if (currentBook.isJoinedVolume) {
    return currentBook.chapters[currentBook.currentChapterIndex];
  }

  for (final chapter in currentBook.chapters) {
    if (position >= chapter.start && position <= chapter.end) {
      return chapter;
    }
  }
  return currentBook.chapters.last;
});

// Current chapter index provider
final currentChapterIndexProvider = StateProvider<int>((ref) {
  final currentBook = ref.watch(currentAudiobookProvider);
  return currentBook?.currentChapterIndex ?? 0;
});

// Audio playing notifier
class AudioPlayingNotifier extends StateNotifier<bool> {
  final AudioService _audioService;

  AudioPlayingNotifier(this._audioService) : super(false) {
    // Listen to audio player state changes
    _audioService.playerStateStream.listen((playerState) {
      state = _audioService.isPlaying;
    });
  }

  Future<void> togglePlayPause() async {
    if (state) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    state = _audioService.isPlaying;
  }
}

// Audiobooks notifier
class AudiobooksNotifier extends StateNotifier<List<Audiobook>> {
  final HiveStorageService _storageService;

  AudiobooksNotifier(this._storageService) : super([]) {
    loadAudiobooks();
  }

  Future<void> loadAudiobooks() async {
    final audiobooks = await _storageService.loadAudiobooks();
    state = audiobooks;
  }

  Future<void> addAudiobook(Audiobook audiobook) async {
    await _storageService.addAudiobook(audiobook);
    state = [...state, audiobook];
  }

  Future<void> updateAudiobook(Audiobook audiobook) async {
    await _storageService.updateAudiobook(audiobook);
    state = [
      for (final book in state)
        if (book.id == audiobook.id) audiobook else book
    ];
  }

  Future<void> deleteAudiobooks(Set<String> ids) async {
    for (final id in ids) {
      await _storageService.deleteAudiobook(id);
    }
    state = state.where((book) => !ids.contains(book.id)).toList();
  }
}

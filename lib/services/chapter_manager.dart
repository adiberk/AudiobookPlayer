import '../models/audiobook.dart';
import '../services/audio_service.dart';

class ChapterManager {
  static Chapter getCurrentChapter(Audiobook audiobook, Duration position) {
    for (int i = 0; i < audiobook.chapters.length; i++) {
      final chapter = audiobook.chapters[i];
      if (position >= chapter.start && position <= chapter.end) {
        return chapter;
      }
    }
    return audiobook.chapters.last;
  }

  static int getCurrentChapterIndex(Audiobook audiobook, Duration position) {
    for (int i = 0; i < audiobook.chapters.length; i++) {
      final chapter = audiobook.chapters[i];
      if (position >= chapter.start && position <= chapter.end) {
        return i;
      }
    }
    return audiobook.chapters.length - 1;
  }

  static Future<void> handleChapterEnd(
    AudioService audioService,
    Audiobook audiobook,
    int currentChapterIndex,
  ) async {
    if (currentChapterIndex < audiobook.chapters.length - 1) {
      final nextChapter = audiobook.chapters[currentChapterIndex + 1];
      await audioService.seek(nextChapter.start);
      await audioService.play();
    } else {
      await audioService.pause();
    }
  }

  static Future<void> skipToNextChapter(
    AudioService audioService,
    Audiobook audiobook,
    Duration currentPosition,
  ) async {
    final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
    if (currentIndex < audiobook.chapters.length - 1) {
      final nextChapter = audiobook.chapters[currentIndex + 1];
      await audioService.seek(nextChapter.start);
    }
  }

  static Future<void> skipToPreviousChapter(
    AudioService audioService,
    Audiobook audiobook,
    Duration currentPosition,
  ) async {
    final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
    if (currentIndex > 0) {
      final previousChapter = audiobook.chapters[currentIndex - 1];
      await audioService.seek(previousChapter.start);
    }
  }
}

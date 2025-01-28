import '../models/audiobook.dart';
import '../services/audio_service.dart';

class ChapterManager {
  static Chapter getCurrentChapter(Audiobook audiobook, Duration position) {
    if (audiobook.isJoinedVolume) {
      return audiobook.chapters[audiobook.currentChapterIndex];
    }

    for (int i = 0; i < audiobook.chapters.length; i++) {
      final chapter = audiobook.chapters[i];
      if (position >= chapter.start && position <= chapter.end) {
        return chapter;
      }
    }
    return audiobook.chapters.last;
  }

  static int getCurrentChapterIndex(Audiobook audiobook, Duration position) {
    if (audiobook.isJoinedVolume) {
      return audiobook.currentChapterIndex;
    }

    for (int i = 0; i < audiobook.chapters.length; i++) {
      final chapter = audiobook.chapters[i];
      if (position >= chapter.start && position <= chapter.end) {
        return i;
      }
    }
    return audiobook.chapters.length - 1;
  }

  static Future<void> skipToNextChapter(
    AudioService audioService,
    Audiobook audiobook,
    Duration currentPosition,
  ) async {
    final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
    if (currentIndex < audiobook.chapters.length - 1) {
      if (audiobook.isJoinedVolume) {
        await audioService.skipToNext();
      } else {
        final nextChapter = audiobook.chapters[currentIndex + 1];
        await audioService
            .seek(nextChapter.start + const Duration(milliseconds: 1));
      }
    }
  }

  static Future<void> skipToPreviousChapter(
    AudioService audioService,
    Audiobook audiobook,
    Duration currentPosition,
  ) async {
    final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
    if (currentIndex > 0) {
      if (audiobook.isJoinedVolume) {
        await audioService.skipToPrevious();
      } else {
        final previousChapter = audiobook.chapters[currentIndex - 1];
        await audioService
            .seek(previousChapter.start + const Duration(milliseconds: 1));
      }
    }
  }
}

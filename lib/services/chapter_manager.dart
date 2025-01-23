import '../models/audiobook.dart';
import '../services/audio_service.dart';

class ChapterManager {
  static Chapter getCurrentChapter(Audiobook audiobook, Duration position) {
    if (audiobook.isJoinedVolume) {
      // For joined volumes, use the currentChapterIndex
      return audiobook.chapters[audiobook.currentChapterIndex];
    }

    // For single files, calculate based on position
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
    if (audiobook.isJoinedVolume) {
      final currentIndex = audioService.currentIndex;
      if (currentIndex < audiobook.chapters.length - 1) {
        await audioService.seekToChapter(currentIndex + 1);
      }
    } else {
      final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
      if (currentIndex < audiobook.chapters.length - 1) {
        // Instead of seeking to the end, directly seek to the start of next chapter
        final nextChapter = audiobook.chapters[currentIndex + 1];
        await audioService.seek(nextChapter.start + Duration(milliseconds: 1));
        // Update the current chapter index in the audiobook
        await audioService.updateCurrentChapter(currentIndex + 1);
        final nextIndex = getCurrentChapterIndex(
            audiobook, nextChapter.start + Duration(milliseconds: 1));
        audiobook.currentChapterIndex = nextIndex;
      }
    }
  }

  static Future<void> skipToPreviousChapter(
    AudioService audioService,
    Audiobook audiobook,
    Duration currentPosition,
  ) async {
    if (audiobook.isJoinedVolume) {
      final currentIndex = audioService.currentIndex;
      if (currentIndex > 0) {
        await audioService.seekToChapter(currentIndex - 1);
        await audioService.updateCurrentChapter(currentIndex - 1);
      }
    } else {
      final currentIndex = getCurrentChapterIndex(audiobook, currentPosition);
      if (currentIndex > 0) {
        final previousChapter = audiobook.chapters[currentIndex - 1];
        await audioService
            .seek(previousChapter.start + Duration(milliseconds: 1));
        // Update the current chapter index in the audiobook
        await audioService.updateCurrentChapter(currentIndex - 1);
        final nextIndex = getCurrentChapterIndex(
            audiobook, previousChapter.start + Duration(milliseconds: 1));
        audiobook.currentChapterIndex = nextIndex;
      }
    }
  }

  static Future<void> handleChapterEnd(
    AudioService audioService,
    Audiobook audiobook,
    int currentChapterIndex,
  ) async {
    if (currentChapterIndex < audiobook.chapters.length - 1) {
      if (audiobook.isJoinedVolume) {
        await audioService.seekToChapter(currentChapterIndex + 1);
      } else {
        final nextChapter = audiobook.chapters[currentChapterIndex + 1];
        await audioService.seek(nextChapter.start);
        await audioService.updateCurrentChapter(currentChapterIndex + 1);
      }
      await audioService.play();
    } else {
      await audioService.pause();
    }
  }
}

import 'dart:async';
import '../models/audiobook.dart';
import 'storage_service.dart';
import 'import_service.dart';

class LibraryManager {
  final StorageService _storageService = StorageService();
  final ImportService _importService = ImportService();

  final _audiobooksController = StreamController<List<Audiobook>>.broadcast();
  Stream<List<Audiobook>> get audiobooksStream => _audiobooksController.stream;

  LibraryManager() {
    _loadAudiobooks();
  }

  Future<void> _loadAudiobooks() async {
    final audiobooks = await _storageService.loadAudiobooks();
    _audiobooksController.add(audiobooks);
  }

  Future<void> importFiles() async {
    final importedBooks = await _importService.importFiles();
    for (var book in importedBooks) {
      await _storageService.addAudiobook(book);
    }
    await _loadAudiobooks();
  }

  Future<void> importFolder() async {
    final importedBook = await _importService.importFolder();
    if (importedBook != null) {
      await _storageService.addAudiobook(importedBook);
      await _loadAudiobooks();
    }
  }

  Future<void> updateAudiobook(Audiobook audiobook) async {
    await _storageService.updateAudiobook(audiobook);
    await _loadAudiobooks();
  }

  Future<void> toggleJoinedVolume(String audiobookId, bool joined) async {
    final audiobooks = await _storageService.loadAudiobooks();
    final index = audiobooks.indexWhere((book) => book.id == audiobookId);
    if (index != -1) {
      final updatedBook = audiobooks[index].copyWith(isJoinedVolume: joined);
      await updateAudiobook(updatedBook);
    }
  }

  Future<void> deleteAudiobooks(Set<String> ids) async {
    for (var id in ids) {
      await _storageService.deleteAudiobook(id);
    }
    await _loadAudiobooks();
  }

  void dispose() {
    _audiobooksController.close();
  }
}

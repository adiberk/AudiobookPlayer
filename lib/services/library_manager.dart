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
    final importedBooks = await _importService.importFolder();
    for (var book in importedBooks) {
      await _storageService.addAudiobook(book);
    }
    await _loadAudiobooks();
  }

  Future<void> updateAudiobook(Audiobook audiobook) async {
    await _storageService.updateAudiobook(audiobook);
    await _loadAudiobooks();
  }

  Future<void> deleteAudiobook(String id) async {
    await _storageService.deleteAudiobook(id);
    await _loadAudiobooks();
  }

  void dispose() {
    _audiobooksController.close();
  }
}

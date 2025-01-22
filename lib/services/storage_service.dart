import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audiobook.dart';

class StorageService {
  static const String _audiobooksKey = 'audiobooks';

  Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
    final prefs = await SharedPreferences.getInstance();
    final audiobooksJson = audiobooks.map((book) => book.toJson()).toList();
    await prefs.setString(_audiobooksKey, json.encode(audiobooksJson));
  }

  Future<List<Audiobook>> loadAudiobooks() async {
    final prefs = await SharedPreferences.getInstance();
    final audiobooksString = prefs.getString(_audiobooksKey);
    if (audiobooksString == null) return [];

    try {
      final audiobooksJson = json.decode(audiobooksString) as List;
      return audiobooksJson
          .map((bookJson) => Audiobook.fromJson(bookJson))
          .toList();
    } catch (e) {
      print('Error loading audiobooks: $e');
      return [];
    }
  }

  Future<void> addAudiobook(Audiobook audiobook) async {
    final audiobooks = await loadAudiobooks();
    audiobooks.add(audiobook);
    await saveAudiobooks(audiobooks);
  }

  Future<void> updateAudiobook(Audiobook audiobook) async {
    final audiobooks = await loadAudiobooks();
    final index = audiobooks.indexWhere((book) => book.id == audiobook.id);
    if (index != -1) {
      audiobooks[index] = audiobook;
      await saveAudiobooks(audiobooks);
    }
  }

  Future<void> deleteAudiobook(String id) async {
    final audiobooks = await loadAudiobooks();
    audiobooks.removeWhere((book) => book.id == id);
    await saveAudiobooks(audiobooks);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audiobook.dart';

class StorageService {
  static const String _key = 'audiobooks';

  static Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
    final prefs = await SharedPreferences.getInstance();
    final audiobooksJson = audiobooks.map((book) => book.toJson()).toList();
    await prefs.setString(_key, json.encode(audiobooksJson));
  }

  static Future<List<Audiobook>> loadAudiobooks() async {
    final prefs = await SharedPreferences.getInstance();
    final audiobooksString = prefs.getString(_key);
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
}

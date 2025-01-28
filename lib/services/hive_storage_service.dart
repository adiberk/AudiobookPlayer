import 'package:hive_flutter/hive_flutter.dart';
import '../models/audiobook.dart';

class HiveStorageService {
  static const String _audiobooksBoxName = 'audiobooks';
  late Box _audiobooksBox;

  static final HiveStorageService _instance = HiveStorageService._internal();
  factory HiveStorageService() => _instance;
  HiveStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    _audiobooksBox = await Hive.openBox(_audiobooksBoxName);
  }

  Map<String, dynamic> _convertMapToStringDynamic(Map map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _convertMapToStringDynamic(value));
      } else if (value is List) {
        return MapEntry(key.toString(), _convertListItems(value));
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  List _convertListItems(List items) {
    return items.map((item) {
      if (item is Map) {
        return _convertMapToStringDynamic(item);
      } else if (item is List) {
        return _convertListItems(item);
      } else {
        return item;
      }
    }).toList();
  }

  Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
    final audiobooksJson = audiobooks.map((book) => book.toJson()).toList();
    await _audiobooksBox.put('all_audiobooks', {'books': audiobooksJson});
  }

  Future<List<Audiobook>> loadAudiobooks() async {
    try {
      final data = _audiobooksBox.get('all_audiobooks');
      if (data == null) return [];

      final Map<String, dynamic> convertedData =
          _convertMapToStringDynamic(data);
      final List audiobooksJson = (convertedData['books'] as List?) ?? [];

      return audiobooksJson.map((bookJson) {
        final Map<String, dynamic> convertedJson =
            _convertMapToStringDynamic(bookJson as Map);
        return Audiobook.fromJson(convertedJson);
      }).toList();
    } catch (e) {
      print('Error loading audiobooks: $e');
      print('Stack trace: ${StackTrace.current}');
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

  Future<void> clear() async {
    await _audiobooksBox.clear();
  }
}

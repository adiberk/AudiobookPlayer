import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _player = AudioPlayer();
  Audiobook? _currentBook;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> setAudiobook(Audiobook book) async {
    try {
      if (_currentBook?.id != book.id) {
        await _player.stop();
        _currentBook = book;
        await _player.setFilePath(book.path);
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

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  Future<void> dispose() async {
    await _player.dispose();
  }
}

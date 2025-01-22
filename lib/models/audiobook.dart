import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Chapter {
  final String title;
  final Duration start;
  final Duration end;

  Chapter({
    required this.title,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'start': start.inMilliseconds,
        'end': end.inMilliseconds,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        title: json['title'],
        start: Duration(milliseconds: json['start']),
        end: Duration(milliseconds: json['end']),
      );
}

class Audiobook {
  final String id; // Add a unique identifier
  final String title;
  final String author;
  final String duration;
  final String path;
  final Uint8List? coverImage;
  final List<Chapter> chapters;
  Duration currentPosition;
  int currentChapterIndex;

  Audiobook({
    String? id,
    required this.title,
    required this.author,
    required this.duration,
    required this.path,
    this.coverImage,
    this.chapters = const [],
    this.currentPosition = Duration.zero,
    this.currentChapterIndex = 0,
  }) : id = id ?? Uuid().v4(); // Use uuid package for generating unique IDs

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'duration': duration,
        'path': path,
        'coverImage': coverImage != null ? base64Encode(coverImage!) : null,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'currentPosition': currentPosition.inMilliseconds,
        'currentChapterIndex': currentChapterIndex,
      };

  factory Audiobook.fromJson(Map<String, dynamic> json) => Audiobook(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        duration: json['duration'],
        path: json['path'],
        coverImage: json['coverImage'] != null
            ? base64Decode(json['coverImage'])
            : null,
        chapters:
            (json['chapters'] as List).map((c) => Chapter.fromJson(c)).toList(),
        currentPosition: Duration(milliseconds: json['currentPosition']),
        currentChapterIndex: json['currentChapterIndex'],
      );
}

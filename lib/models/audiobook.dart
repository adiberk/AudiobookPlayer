import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Chapter {
  final String title;
  final Duration start;
  final Duration end;
  final String? filePath; // Added for folder-based chapters

  Chapter({
    required this.title,
    required this.start,
    required this.end,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'start': start.inMilliseconds,
        'end': end.inMilliseconds,
        'filePath': filePath,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        title: json['title'],
        start: Duration(milliseconds: json['start']),
        end: Duration(milliseconds: json['end']),
        filePath: json['filePath'],
      );
}

class Audiobook {
  final String id;
  final String title;
  final String author;
  final String duration;
  final String path;
  final Uint8List? coverImage;
  final List<Chapter> chapters;
  final bool isFolder; // New field
  final bool isJoinedVolume; // New field
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
    this.isFolder = false, // Default to false
    this.isJoinedVolume = false, // Default to false
    this.currentPosition = Duration.zero,
    this.currentChapterIndex = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'duration': duration,
        'path': path,
        'coverImage': coverImage != null ? base64Encode(coverImage!) : null,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'isFolder': isFolder,
        'isJoinedVolume': isJoinedVolume,
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
        isFolder: json['isFolder'] ?? false,
        isJoinedVolume: json['isJoinedVolume'] ?? false,
        currentPosition: Duration(milliseconds: json['currentPosition']),
        currentChapterIndex: json['currentChapterIndex'],
      );

  // Create a copy of the audiobook with modified properties
  Audiobook copyWith({
    String? title,
    String? author,
    String? duration,
    String? path,
    Uint8List? coverImage,
    List<Chapter>? chapters,
    bool? isFolder,
    bool? isJoinedVolume,
    Duration? currentPosition,
    int? currentChapterIndex,
  }) {
    return Audiobook(
      id: id, // Keep the same ID
      title: title ?? this.title,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      path: path ?? this.path,
      coverImage: coverImage ?? this.coverImage,
      chapters: chapters ?? this.chapters,
      isFolder: isFolder ?? this.isFolder,
      isJoinedVolume: isJoinedVolume ?? this.isJoinedVolume,
      currentPosition: currentPosition ?? this.currentPosition,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
    );
  }
}

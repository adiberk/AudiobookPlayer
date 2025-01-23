import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/audiobook.dart';
import '../utils/duration_formatter.dart';
import 'metadata_service.dart';

class ImportService {
  static final List<String> _supportedFormats = [
    'mp3',
    'm4a',
    'm4b',
    'aac',
    'wav'
  ];

  Future<List<Audiobook>> importFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedFormats,
        allowMultiple: true,
      );

      if (result != null) {
        List<Audiobook> importedBooks = [];

        for (var file in result.files) {
          if (file.path != null) {
            final metadata = await MetadataService.extractMetadata(file.path!);

            final audiobook = Audiobook(
              title: metadata['title'] ?? path.basename(file.path!),
              author: metadata['author'] ?? 'Unknown Author',
              duration: metadata['duration']?['formatted'] ?? '00:00:00',
              path: file.path!,
              coverImage: metadata['cover_photo'],
              chapters: (metadata['chapters'] as List<Chapter>?) ?? [],
            );

            importedBooks.add(audiobook);
          }
        }

        return importedBooks;
      }
    } catch (e) {
      print('Error importing files: $e');
    }

    return [];
  }

  Future<Audiobook?> importFolder() async {
    try {
      String? folderPath = await FilePicker.platform.getDirectoryPath();

      if (folderPath != null) {
        final directory = Directory(folderPath);
        List<Chapter> folderChapters = [];
        Uint8List? firstCoverImage;
        Duration totalDuration = Duration.zero;

        // Get all audio files in the folder
        List<FileSystemEntity> files = directory
            .listSync()
            .where((entity) =>
                entity is File &&
                _supportedFormats.contains(
                    path.extension(entity.path).toLowerCase().substring(1)))
            .toList();

        // Sort files by name to maintain order
        files.sort((a, b) => a.path.compareTo(b.path));

        for (var entity in files) {
          if (entity is File) {
            final metadata = await MetadataService.extractMetadata(entity.path);

            // Store first found cover image
            if (firstCoverImage == null && metadata['cover_photo'] != null) {
              firstCoverImage = metadata['cover_photo'];
            }

            // Calculate duration
            Duration fileDuration = Duration(
                seconds: (metadata['duration']?['seconds'] ?? 0.0).round());

            // Create chapter from file
            Chapter chapter = Chapter(
              title: metadata['title'] ?? path.basename(entity.path),
              start: totalDuration,
              end: totalDuration + fileDuration,
              filePath: entity.path,
            );

            folderChapters.add(chapter);
            totalDuration += fileDuration;
          }
        }

        if (folderChapters.isNotEmpty) {
          return Audiobook(
            title: path.basename(folderPath),
            author: 'Various Artists',
            duration: DurationFormatter.format(totalDuration),
            path: folderPath,
            coverImage: firstCoverImage,
            chapters: folderChapters,
            isFolder: true,
            isJoinedVolume: false,
          );
        }
      }
    } catch (e) {
      print('Error importing folder: $e');
    }

    return null;
  }

  Future<Audiobook> convertToJoinedVolume(Audiobook folderBook) async {
    if (!folderBook.isFolder) return folderBook;

    return folderBook.copyWith(
      isJoinedVolume: true,
    );
  }
}

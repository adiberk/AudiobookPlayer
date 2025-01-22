import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/audiobook.dart';
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

  Future<List<Audiobook>> importFolder() async {
    try {
      String? folderPath = await FilePicker.platform.getDirectoryPath();

      if (folderPath != null) {
        final directory = Directory(folderPath);
        List<Audiobook> importedBooks = [];

        await for (var entity in directory.list(recursive: false)) {
          if (entity is File) {
            String extension = path.extension(entity.path).toLowerCase();
            if (_supportedFormats.contains(extension.replaceAll('.', ''))) {
              final metadata =
                  await MetadataService.extractMetadata(entity.path);

              final audiobook = Audiobook(
                title: metadata['title'] ?? path.basename(entity.path),
                author: metadata['author'] ?? 'Unknown Author',
                duration: metadata['duration']?['formatted'] ?? '00:00:00',
                path: entity.path,
                coverImage: metadata['cover_photo'],
                chapters: (metadata['chapters'] as List<Chapter>?) ?? [],
              );

              importedBooks.add(audiobook);
            }
          }
        }

        return importedBooks;
      }
    } catch (e) {
      print('Error importing folder: $e');
    }

    return [];
  }
}

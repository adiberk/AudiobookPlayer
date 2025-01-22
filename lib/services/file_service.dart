import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> pickAudiobookFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3', 'm4a', 'm4b'],
  );

  if (result != null && result.files.single.path != null) {
    File file = File(result.files.single.path!);

    // Move file to app storage
    Directory appDir = await getApplicationDocumentsDirectory();
    String newPath = "${appDir.path}/${file.uri.pathSegments.last}";
    await file.copy(newPath);

    return newPath;
  }
  return null;
}

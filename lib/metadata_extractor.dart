// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'dart:io';
// import 'dart:convert';

// class MetadataExtractor {
//   static Future<Map<String, dynamic>> extractMetadata(String filePath) async {
//     Map<String, dynamic> metadata = {
//       'cover_photo': null,
//       'chapters': [],
//       'duration': null,
//       'title': null,
//       'author': null,
//     };

//     try {
//       // Extract cover art
//       final String coverOutputPath = '${Directory.systemTemp.path}/cover.jpg';

//       final coverResult = await FFmpegKit.execute(
//           '-i "$filePath" -an -vcodec copy "$coverOutputPath"');

//       if (ReturnCode.isSuccess(await coverResult.getReturnCode())) {
//         final coverFile = File(coverOutputPath);
//         if (await coverFile.exists()) {
//           metadata['cover_photo'] = await coverFile.readAsBytes();
//           await coverFile.delete(); // Clean up temporary file
//         }
//       }

//       // Get metadata using FFprobe
//       final probeResult = await FFprobeKit.execute(
//           '-v quiet -print_format json -show_chapters -show_format -show_streams "$filePath"');

//       if (ReturnCode.isSuccess(await probeResult.getReturnCode())) {
//         final jsonOutput = await probeResult.getOutput();
//         if (jsonOutput != null) {
//           try {
//             final Map<String, dynamic> probeData = json.decode(jsonOutput);

//             // Extract chapters
//             if (probeData.containsKey('chapters')) {
//               metadata['chapters'] = probeData['chapters'];
//             }

//             // Extract format metadata
//             if (probeData.containsKey('format')) {
//               var format = probeData['format'];

//               // Extract duration
//               if (format.containsKey('duration')) {
//                 double durationSeconds = double.parse(format['duration']);
//                 metadata['duration'] = {
//                   'seconds': durationSeconds,
//                   'formatted': formatDuration(durationSeconds),
//                   'formatted_hours': formatDurationWithHours(durationSeconds),
//                 };
//               }

//               // Extract tags from format metadata
//               if (format.containsKey('tags')) {
//                 var tags = format['tags'];
//                 metadata['title'] = tags['title'] ??
//                     tags['TITLE'] ??
//                     _getFileNameWithoutExtension(filePath);

//                 metadata['author'] = tags['artist'] ??
//                     tags['ARTIST'] ??
//                     tags['author'] ??
//                     tags['AUTHOR'] ??
//                     tags['album_artist'] ??
//                     tags['ALBUM_ARTIST'] ??
//                     "Unknown Author";
//               }
//             }

//             // If title/author not found in format tags, check stream metadata
//             if (probeData.containsKey('streams') &&
//                 (metadata['title'] == null || metadata['author'] == null)) {
//               for (var stream in probeData['streams']) {
//                 if (stream.containsKey('tags')) {
//                   var tags = stream['tags'];

//                   // Only set if not already set from format metadata
//                   metadata['title'] ??= tags['title'] ?? tags['TITLE'];

//                   metadata['author'] ??= tags['artist'] ??
//                       tags['ARTIST'] ??
//                       tags['author'] ??
//                       tags['AUTHOR'] ??
//                       tags['album_artist'] ??
//                       tags['ALBUM_ARTIST'];
//                 }
//               }
//             }

//             // Final fallback for title if nothing found in metadata
//             metadata['title'] ??= _getFileNameWithoutExtension(filePath);
//             metadata['author'] ??= "Unknown Author";
//           } catch (e) {
//             print('Error parsing JSON metadata: $e');
//           }
//         }
//       }

//       return metadata;
//     } catch (e) {
//       print('Error extracting metadata: $e');
//       return metadata;
//     }
//   }

//   static String _getFileNameWithoutExtension(String filePath) {
//     String fileName = filePath.split('/').last;
//     return fileName.substring(0, fileName.lastIndexOf('.'));
//   }

//   static String formatDurationWithHours(double seconds) {
//     Duration duration = Duration(seconds: seconds.round());
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secs = twoDigits(duration.inSeconds.remainder(60));
//     return "$hours:$minutes:$secs";
//   }

//   static String formatDuration(double seconds) {
//     Duration duration = Duration(seconds: seconds.round());
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String secs = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$secs";
//   }
// }

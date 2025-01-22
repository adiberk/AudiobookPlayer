// import 'package:flutter/material.dart';
// import '../services/import_service.dart';
// import '../services/storage_service.dart';

// class ImportButton extends StatelessWidget {
//   final Function() onImportComplete;

//   const ImportButton({
//     Key? key,
//     required this.onImportComplete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.add),
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (BuildContext context) {
//             return SafeArea(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.audio_file),
//                     title: const Text('Import Single File'),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       final importService = ImportService();
//                       final storageService = StorageService();

//                       final audiobook = await importService.importSingleFile();
//                       if (audiobook != null) {
//                         await storageService.addAudiobook(audiobook);
//                         onImportComplete();
//                       }
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.folder),
//                     title: const Text('Import Folder'),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       final importService = ImportService();
//                       final storageService = StorageService();

//                       final audiobook = await importService.importFolder();
//                       if (audiobook != null) {
//                         await storageService.addAudiobook(audiobook);
//                         onImportComplete();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

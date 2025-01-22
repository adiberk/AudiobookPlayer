// // audio_player_screen.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// import 'models/audiobook.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final Audiobook audiobook;
//   final AudioPlayer audioPlayer;

//   AudioPlayerScreen({
//     required this.audiobook,
//     required this.audioPlayer,
//   });

//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   Duration? duration;
//   Duration position = Duration.zero;
//   bool isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     setupAudioPlayer();
//   }

//   Future<void> setupAudioPlayer() async {
//     // Configure audio session
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.speech());

//     // Listen to player state changes
//     widget.audioPlayer.playerStateStream.listen((state) {
//       if (mounted) {
//         setState(() {
//           isPlaying = state.playing;
//         });
//       }
//     });

//     // Listen to duration changes
//     widget.audioPlayer.durationStream.listen((newDuration) {
//       if (mounted) {
//         setState(() {
//           duration = newDuration;
//         });
//       }
//     });

//     // Listen to position changes
//     widget.audioPlayer.positionStream.listen((newPosition) {
//       if (mounted) {
//         setState(() {
//           position = newPosition;
//         });
//       }
//     });
//   }

//   String formatDuration(Duration? duration) {
//     if (duration == null) return '--:--';
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       minChildSize: 0.1,
//       maxChildSize: 0.9,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: ListView(
//             controller: scrollController,
//             children: [
//               // Drag handle
//               Center(
//                 child: Container(
//                   margin: EdgeInsets.symmetric(vertical: 8),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[600],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               // Cover art
//               Container(
//                 height: 300,
//                 margin: EdgeInsets.all(20),
//                 child: widget.audiobook.coverImage != null
//                     ? Image.memory(
//                         widget.audiobook.coverImage as Uint8List,
//                         fit: BoxFit.contain,
//                       )
//                     : Container(
//                         color: Colors.grey[800],
//                         child: Icon(Icons.audiotrack,
//                             size: 100, color: Colors.white54),
//                       ),
//               ),
//               // Title and author
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.audiobook.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       widget.audiobook.author,
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Progress bar
//               Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Slider(
//                       value: position.inSeconds.toDouble(),
//                       min: 0,
//                       max: duration?.inSeconds.toDouble() ?? 0,
//                       onChanged: (value) async {
//                         final position = Duration(seconds: value.toInt());
//                         await widget.audioPlayer.seek(position);
//                       },
//                       activeColor: Colors.blue,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             formatDuration(position),
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                           Text(
//                             formatDuration(duration),
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Playback controls
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.replay_30, color: Colors.white, size: 36),
//                     onPressed: () {
//                       widget.audioPlayer.seek(position - Duration(seconds: 30));
//                     },
//                   ),
//                   SizedBox(width: 32),
//                   IconButton(
//                     icon: Icon(
//                       isPlaying
//                           ? Icons.pause_circle_filled
//                           : Icons.play_circle_filled,
//                       color: Colors.blue,
//                       size: 64,
//                     ),
//                     onPressed: () {
//                       if (isPlaying) {
//                         widget.audioPlayer.pause();
//                       } else {
//                         widget.audioPlayer.play();
//                       }
//                     },
//                   ),
//                   SizedBox(width: 32),
//                   IconButton(
//                     icon: Icon(Icons.forward_30, color: Colors.white, size: 36),
//                     onPressed: () {
//                       widget.audioPlayer.seek(position + Duration(seconds: 30));
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

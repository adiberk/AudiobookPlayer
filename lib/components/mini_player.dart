import 'package:flutter/material.dart';
import '../models/audiobook.dart';

class MiniPlayer extends StatelessWidget {
  final Audiobook audiobook;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.audiobook,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (audiobook.coverImage != null)
              SizedBox(
                width: 64,
                height: 64,
                child: Image.memory(
                  audiobook.coverImage!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                color: Colors.grey[800],
                child: const Icon(Icons.book),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audiobook.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audiobook.author,
                      style: TextStyle(color: Colors.grey[400]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.forward_30),
              onPressed: () {
                // Skip forward functionality will be handled by the parent
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/audiobook.dart';

class AudiobookListItem extends StatelessWidget {
  final Audiobook audiobook;
  final Function(Audiobook) onDelete;
  final VoidCallback onTap;

  const AudiobookListItem({
    super.key,
    required this.audiobook,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(audiobook.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(audiobook),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Audiobook'),
              content:
                  Text('Are you sure you want to delete "${audiobook.title}"?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 50,
              height: 50,
              child: audiobook.coverImage != null
                  ? Image.memory(
                      audiobook.coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.book),
                    ),
            ),
          ),
          title: Text(
            audiobook.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(audiobook.author),
              const SizedBox(height: 4),
              Text(
                audiobook.duration,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            '0%',
            style: TextStyle(color: Colors.grey[400]),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

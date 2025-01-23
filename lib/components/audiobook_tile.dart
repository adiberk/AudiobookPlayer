import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../screens/folder_contents_screen.dart';
import '../services/audio_service.dart';
import '../services/library_manager.dart';

class AudiobookTile extends StatelessWidget {
  final Audiobook audiobook;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool selectionMode;
  final LibraryManager libraryManager;
  final AudioService audioService;

  const AudiobookTile({
    Key? key,
    required this.audiobook,
    required this.onTap,
    required this.onLongPress,
    required this.libraryManager,
    required this.audioService,
    this.isSelected = false,
    this.selectionMode = false,
  }) : super(key: key);

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (audiobook.isFolder && !audiobook.isJoinedVolume)
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Join as Single Volume'),
                  onTap: () async {
                    Navigator.pop(context);
                    final updatedBook =
                        audiobook.copyWith(isJoinedVolume: true);
                    await libraryManager.updateAudiobook(updatedBook);
                  },
                ),
              if (audiobook.isFolder && audiobook.isJoinedVolume)
                ListTile(
                  leading: const Icon(Icons.playlist_remove),
                  title: const Text('Unjoin Volume'),
                  onTap: () async {
                    Navigator.pop(context);
                    final updatedBook =
                        audiobook.copyWith(isJoinedVolume: false);
                    await libraryManager.updateAudiobook(updatedBook);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Audiobook'),
                      content: const Text(
                          'Are you sure you want to delete this audiobook?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await libraryManager.deleteAudiobooks({audiobook.id});
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (audiobook.isFolder && !audiobook.isJoinedVolume) {
          // Navigate to folder contents
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderContentsScreen(
                folderBook: audiobook,
                audioService: audioService,
                libraryManager: libraryManager,
              ),
            ),
          );
        } else {
          onTap();
        }
      },
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // Cover Image
              SizedBox(
                width: 45,
                height: 45,
                child: Stack(
                  children: [
                    if (audiobook.coverImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          audiobook.coverImage!,
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          audiobook.isFolder ? Icons.folder : Icons.book,
                          color: Colors.white,
                        ),
                      ),
                    if (selectionMode)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5)
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Title, Author, and Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audiobook.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      audiobook.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          audiobook.duration,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                        ),
                        if (audiobook.isFolder)
                          Text(
                            ' • ${audiobook.chapters.length} files',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // More Options Button
              if (!selectionMode)
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () => _showOptions(context),
                )
              else
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

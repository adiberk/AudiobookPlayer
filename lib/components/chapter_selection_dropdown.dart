import 'package:flutter/material.dart';

import '../models/audiobook.dart';
import '../utils/duration_formatter.dart';

class ChapterSelectionSheet extends StatelessWidget {
  final List<Chapter> chapters;
  final Chapter currentChapter;
  final Function(Chapter) onChapterSelected;

  const ChapterSelectionSheet({
    Key? key,
    required this.chapters,
    required this.currentChapter,
    required this.onChapterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text(chapter.title),
                  subtitle: Text(
                    DurationFormatter.format(chapter.end - chapter.start),
                  ),
                  selected: chapter.title == currentChapter.title,
                  leading: Text('${index + 1}'),
                  onTap: () => onChapterSelected(chapter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

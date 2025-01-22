import 'package:flutter/material.dart';
import '../models/audiobook.dart';
import '../utils/duration_formatter.dart';

class ChapterList extends StatelessWidget {
  final List<Chapter> chapters;
  final ValueChanged<Chapter> onChapterSelected;

  const ChapterList({
    super.key,
    required this.chapters,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text(chapter.title),
                  subtitle: Text(
                    '${DurationFormatter.format(chapter.start)} - ${DurationFormatter.format(chapter.end)}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
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

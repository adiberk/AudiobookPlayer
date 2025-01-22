import 'package:flutter/material.dart';

import '../models/audiobook.dart';
import '../services/audio_service.dart';
import '../utils/duration_formatter.dart';

class ChaptersList extends StatelessWidget {
  final List<Chapter> chapters;
  final AudioService audioService;
  final Chapter currentChapter;

  const ChaptersList({
    Key? key,
    required this.chapters,
    required this.audioService,
    required this.currentChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
          onTap: () async {
            await audioService.seek(chapter.start);
          },
        );
      },
    );
  }
}

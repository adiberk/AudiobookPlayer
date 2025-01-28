import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';
import '../utils/duration_formatter.dart';

class ChaptersList extends ConsumerWidget {
  final List<Chapter> chapters;
  final Chapter currentChapter;

  const ChaptersList({
    Key? key,
    required this.chapters,
    required this.currentChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);

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
            ref.read(currentChapterIndexProvider.notifier).state = index;
          },
        );
      },
    );
  }
}

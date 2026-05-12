import 'package:flutter/material.dart';
import '../models/comic.dart';
import '../services/comic_service.dart';
import 'reader_screen.dart';

class ComicDetailScreen extends StatefulWidget {
  final Comic comic;

  const ComicDetailScreen({Key? key, required this.comic}) : super(key: key);

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  final ComicService _comicService = ComicService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.comic.title)),
      body: Column(
        children: [
          // Bagian Header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sinopsis: ${widget.comic.description}',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Divider(),
          // Bagian Daftar Chapter
          Expanded(
            child: FutureBuilder(
              future: _comicService.getChaptersByComicId(
                widget.comic.id as int,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada chapter.'));
                }

                final chapters = snapshot.data!;
                return ListView.builder(
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      title: Text('Chapter ${chapter.chapterNumber}'),
                      subtitle: Text(chapter.title),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Pindah ke layar baca komik saat chapter diklik
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReaderScreen(chapter: chapter),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/chapter.dart';

class ReaderScreen extends StatelessWidget {
  final Chapter chapter;

  const ReaderScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ch. ${chapter.chapterNumber} - ${chapter.title}'),
        backgroundColor: Colors.black, // Tema gelap
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: chapter.imageUrls.isEmpty
          ? const Center(
              child: Text(
                'Halaman komik tidak ditemukan.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: chapter.imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  chapter.imageUrls[index],
                  fit: BoxFit.fitWidth,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

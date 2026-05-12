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
        backgroundColor: Colors.black, // Tema gelap lebih nyaman untuk membaca
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black, // Background layar baca
      body: chapter.imageUrls.isEmpty
          ? const Center(
              child: Text(
                'Halaman komik tidak ditemukan.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              // Menghilangkan efek pantulan scroll di ujung (opsional)
              physics: const ClampingScrollPhysics(),
              itemCount: chapter.imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  chapter.imageUrls[index],
                  fit:
                      BoxFit.fitWidth, // Memastikan gambar memenuhi lebar layar
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    // Tampilan saat gambar sedang di-load
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

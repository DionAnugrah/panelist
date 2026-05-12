import 'package:flutter/material.dart';
import '../../data/models/comic.dart';
import '../../core/widgets/comic_card.dart';
import 'bookmark_service.dart';
import '../comic/infokomik.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Comic> bookmarkedComics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    // Panggil service untuk tarik data dari Supabase
    final data = await BookmarkService().fetchBookmarks();

    setState(() {
      bookmarkedComics = data; // Masukkan data ke variabel global kamu
      _isLoading = false; // Matikan loading
    });
  }
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Tampilkan loading kalau data masih ditarik
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bookmark',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${bookmarkedComics.length} komik tersimpan',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bookmarkedComics.isEmpty
                ? _buildEmpty(scheme)
                : _buildGrid(),
          ), // Ganti ke _buildList() kalau mau tampilan list
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: bookmarkedComics.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            // 1. Pindah halaman dari sini
            final adaPerubahan = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InfoKomikScreen(comic: bookmarkedComics[index]),
              ),
            );
              _loadBookmarks();
          },
          child: AbsorbPointer(
            child: ComicCard(comic: bookmarkedComics[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 72,
            color: scheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada bookmark',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan komik favoritmu di sini',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

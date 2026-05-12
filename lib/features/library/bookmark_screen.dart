import 'package:flutter/material.dart';
import '../../data/models/comic.dart';
import '../../core/widgets/comic_card.dart';
import 'bookmark_service.dart';
import '../../data/models/genres.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  int _viewMode = 0;
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: _viewMode == 0
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _viewMode = 0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_list,
                        color: _viewMode == 1
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _viewMode = 1),
                    ),
                  ],
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
                : _viewMode == 0
                ? _buildGrid()
                : _buildList(scheme),
          ),
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
      itemBuilder: (context, index) =>
          ComicCard(comic: bookmarkedComics[index]),
    );
  }

  Widget _buildList(ColorScheme scheme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookmarkedComics.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final comic = bookmarkedComics[index];
        final cardColor = Theme.of(context).cardColor;

        return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar Thumbnail dari URL
                    Image.network(
                      comic.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: scheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    // Overlay Gradient agar teks chapter lebih terbaca (opsional)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.whatshot_rounded,
                        size: 12,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          comic.latestChapter,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      }
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

import 'package:flutter/material.dart';
import 'package:panelist/data/models/comic.dart';
import 'package:panelist/data/models/comic_detail.dart';
import 'package:panelist/data/repositories/comic_repository_impl.dart';
import 'package:panelist/features/profile/histori_service.dart';
import 'package:panelist/features/reader/presentation/baca_komik.dart';
import '../library/bookmark_service.dart';

class InfoKomikScreen extends StatefulWidget {
  final Comic comic;

  const InfoKomikScreen({super.key, required this.comic});

  @override
  State<InfoKomikScreen> createState() => _InfoKomikScreenState();
}

class _InfoKomikScreenState extends State<InfoKomikScreen> {
  ComicDetail? comicDetail;
  bool _isLoading = true;
  bool _isBookmarked = false;
  List<String> _alreadyReadChapters = [];

  @override
  void initState() {
    super.initState();
    _initialFetch();
  }

  Future<void> _initialFetch() async {
    final repo = ComicRepositoryImpl();
    try {
      final data = await repo.fetchComicDetail(widget.comic.param);
      final bookmarks = await BookmarkService().fetchBookmarks();
      final available = bookmarks.any((b) => b.param == widget.comic.param);
      final history = await HistoryService().fetchHistoryBasedOnParams(
        widget.comic.param,
      );
      if (mounted) {
        setState(() {
          comicDetail = data;
          _isBookmarked = available;
          _alreadyReadChapters = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    debugPrint("Error Fetching: $e");
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (comicDetail == null) {
      return const Scaffold(
        body: Center(child: Text("Data tidak ditemukan atau error.")),
      );
    }

    final baseColor = scheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar / Hero Cover ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: baseColor,
            leading: _buildAppBarAction(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _buildAppBarAction(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                onTap: () async {
                  // Proses simpan/hapus ke database
                  if (_isBookmarked) {
                    await BookmarkService().removeBookmark(widget.comic.param);
                  } else {
                    await BookmarkService().addBookmark(widget.comic);
                  }

                  // Ubah tampilan ikon dan munculkan notif
                  setState(() => _isBookmarked = !_isBookmarked);
                  _showSnackBar(
                    '${comicDetail!.title} ${_isBookmarked ? 'disimpan' : 'dihapus'}',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    comicDetail!.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comicDetail!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: comicDetail!.genre
                              .map((g) => _GenreTag(label: g))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body: Info & Sinopsis ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BacaKomikScreen(
                          chapterTitle: _alreadyReadChapters.isEmpty
                              ? comicDetail!.chapters.last.title
                              : _alreadyReadChapters.last,
                          chapterParam: _alreadyReadChapters.isEmpty
                              ? comicDetail!.chapters.last.param
                              : "${widget.comic.param}-${_alreadyReadChapters.last}",
                          comic: widget.comic,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _alreadyReadChapters.isEmpty
                          ? 'Baca Sekarang'
                          : 'Lanjutkan Membaca ${_alreadyReadChapters.last.split('-').last}',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ExpandableText(
                    text: widget.comic.description.isEmpty
                        ? "Tidak ada deskripsi."
                        : widget.comic.description,
                    scheme: scheme,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Daftar Chapter (${comicDetail!.chapters.length})',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ─── Real Chapter List ──────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final ch = comicDetail!.chapters[index];
              return _ChapterTile(
                title: ch.title,
                date: ch.releaseDate,
                baseColor: baseColor,
                scheme: scheme,
                cardColor: cardColor,
                alreadyRead: _alreadyReadChapters.contains(
                  ch.param.split('-').last,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BacaKomikScreen(
                      chapterTitle: ch.title,
                      chapterParam: ch.param,
                      comic: widget.comic,
                    ),
                  ),
                ),
              );
            }, childCount: comicDetail!.chapters.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: CircleAvatar(
        backgroundColor: Colors.black38,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      onPressed: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

// --- Helper Widgets ---

class _GenreTag extends StatelessWidget {
  final String label;
  const _GenreTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final ColorScheme scheme;
  const _ExpandableText({required this.text, required this.scheme});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.scheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        if (widget.text.length > 150)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Sembunyikan' : 'Baca Selengkapnya'),
          ),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final String title;
  final String date;
  final Color baseColor;
  final ColorScheme scheme;
  final Color cardColor;
  final VoidCallback onTap;
  final bool alreadyRead;

  const _ChapterTile({
    required this.title,
    required this.date,
    required this.baseColor,
    required this.scheme,
    required this.cardColor,
    required this.onTap,
    this.alreadyRead = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extract number from title if possible for the circle icon
    final chapterNum = title.replaceAll(RegExp(r'[^0-9]'), '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListTile(
        onTap: onTap,
        tileColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !alreadyRead
                ? baseColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            chapterNum.isEmpty ? '?' : chapterNum,
            style: TextStyle(color: baseColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: scheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}

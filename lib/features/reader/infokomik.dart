import 'package:flutter/material.dart';
import 'package:panelist/data/models/comic.dart';
import '../library/bookmark_service.dart';
import '../profile/histori_service.dart';

class InfoKomikScreen extends StatefulWidget {
  final Comic comic;

  const InfoKomikScreen({super.key, required this.comic});

  @override
  State<InfoKomikScreen> createState() => _InfoKomikScreenState();
}

class _InfoKomikScreenState extends State<InfoKomikScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _cekStatusBookmark();
  }

  Future<void> _cekStatusBookmark() async {
    final bookmarks = await BookmarkService().fetchBookmarks();
    // Cek apakah param komik ini ada di database
    final sudahAda = bookmarks.any((b) => b.param == widget.comic.param);
    if (mounted) {
      setState(() {
        _isBookmarked = sudahAda;
      });
    }
  }

  // Daftar chapter dummy berdasarkan chapter terakhir dari model baru
  List<_ChapterItem> get _chapters {
    // Parse angka dari latestChapter (misal: "Chapter 120" -> 120)
    final raw = widget.comic.latestChapter.replaceAll(RegExp(r'[^0-9]'), '');
    final total = int.tryParse(raw) ?? 10;
    final count = total > 20 ? 20 : total;

    return List.generate(
      count,
      (i) => _ChapterItem(number: total - i, date: _fakeDate(i)),
    );
  }

  String _fakeDate(int offset) {
    final now = DateTime.now();
    final d = now.subtract(Duration(days: offset * 7));
    return '${d.day} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final comic = widget.comic;
    // Gunakan warna primary tema sebagai fallback karena model baru tidak punya warna spesifik
    final baseColor = scheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar / Hero Cover ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: baseColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _buildAppBarAction(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                onTap: () async {
                  // Proses simpan atau hapus ke database
                  if (_isBookmarked) {
                    await BookmarkService().removeBookmark(comic.param);
                  } else {
                    await BookmarkService().addBookmark(comic);
                  }
                  // Ubah tampilan ikon dan munculkan notif
                  setState(() => _isBookmarked = !_isBookmarked);
                  _showSnackBar(
                    '${comic.title} ${_isBookmarked ? 'disimpan ke bookmark' : 'dihapus dari bookmark'}',
                  );
                },
              ),
              _buildAppBarAction(
                icon: Icons.share_outlined,
                onTap: () => _showSnackBar('Bagikan ${comic.title}'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail Image
                  Image.network(
                    comic.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: baseColor,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Info overlay bottom
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comic.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.update,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comic.latestChapter,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              _showSnackBar('Membaca ${comic.title}'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Baca Sekarang'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sinopsis (Menggunakan description dari model baru)
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
                    text: comic.description.isEmpty
                        ? "Tidak ada deskripsi tersedia."
                        : comic.description,
                    scheme: scheme,
                  ),

                  const SizedBox(height: 24),

                  // Header Chapter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Chapter',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Update Terbaru',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ─── Chapter List ────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final ch = _chapters[index];
              return _ChapterTile(
                chapter: ch,
                comicColor: baseColor,
                scheme: scheme,
                cardColor: cardColor,
                onTap: () async {
                  // SIMPAN RIWAYAT DISINI
                  await HistoryService().saveHistory(
                    param: comic.param,
                    title: comic.title,
                    thumbnail: comic.thumbnail,
                    lastChapter: 'Chapter ${ch.number}',
                  );              
                }
              );
            }, childCount: _chapters.length),
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
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      onPressed: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

// Model Chapter Internal
class _ChapterItem {
  final int number;
  final String date;
  const _ChapterItem({required this.number, required this.date});
}

// Widget untuk Chip Info (Jika ingin menambahkan tag manual nanti)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final Color cardColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Teks yang bisa di-expand
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
            color: widget.scheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (widget.text.length > 100)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Sembunyikan' : 'Baca Selengkapnya',
                style: TextStyle(
                  color: widget.scheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget Item List Chapter
class _ChapterTile extends StatelessWidget {
  final _ChapterItem chapter;
  final Color comicColor;
  final ColorScheme scheme;
  final Color cardColor;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.comicColor,
    required this.scheme,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: comicColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${chapter.number}',
                    style: TextStyle(
                      color: comicColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${chapter.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      chapter.date,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurface.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

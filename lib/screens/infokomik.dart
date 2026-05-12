import 'package:flutter/material.dart';
import '../models/comic.dart';

class InfoKomikScreen extends StatefulWidget {
  final Comic comic;

  const InfoKomikScreen({super.key, required this.comic});

  @override
  State<InfoKomikScreen> createState() => _InfoKomikScreenState();
}

class _InfoKomikScreenState extends State<InfoKomikScreen> {
  bool _isBookmarked = false;

  // Daftar chapter dummy berdasarkan chapter terakhir komik
  List<_ChapterItem> get _chapters {
    // Parse angka chapter dari string "Ch. X"
    final raw = widget.comic.chapter.replaceAll(RegExp(r'[^0-9]'), '');
    final total = int.tryParse(raw) ?? 10;
    final count = total > 20 ? 20 : total; // tampilkan max 20 chapter
    return List.generate(
      count,
      (i) => _ChapterItem(
        number: total - i,
        date: _fakeDate(i),
      ),
    );
  }

  String _fakeDate(int offset) {
    final now = DateTime.now();
    final d = now.subtract(Duration(days: offset * 7));
    return '${d.day} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return names[m];
  }

  // Deskripsi dummy sesuai genre
  String get _description {
    const Map<String, String> desc = {
      'Action':
          'Sebuah kisah epik tentang pertarungan, kekuatan, dan tekad yang tak tergoyahkan. Ikuti perjalanan sang protagonis menghadapi musuh-musuh paling tangguh di dunianya.',
      'Adventure':
          'Petualangan luar biasa melintas benua dan lautan, menemukan harta karun, dan bertemu kawan sejati di setiap sudut dunia.',
      'Comedy':
          'Cerita penuh tawa dan momen hangat yang akan membuat harimu menjadi lebih ceria. Dijamin tidak bisa berhenti senyum!',
      'Drama':
          'Kisah yang penuh emosi dan konflik mendalam antar karakter. Setiap keputusan membawa konsekuensi yang mengubah segalanya.',
      'Fantasy':
          'Dunia penuh keajaiban di mana sihir nyata, makhluk misterius berkeliaran, dan takdir ditulis oleh para dewa.',
      'Horror':
          'Merayap dalam kegelapan, rasa takut menjadi teman setia. Sebuah kisah yang akan membuatmu tidak berani tidur sendirian.',
      'Historical':
          'Berlatar era lampau yang penuh peperangan, kehormatan, dan pengkhianatan. Sejarah ditulis ulang oleh para pemberani.',
      'Romance':
          'Kisah cinta yang mengharukan antara dua jiwa yang dipertemukan takdir, melewati berbagai rintangan demi bersama.',
      'Sports':
          'Semangat kompetisi, keringat keras, dan mimpi besar di lapangan. Buktikan bahwa kerja keras mengalahkan bakat semata.',
    };
    return desc[widget.comic.genre] ??
        'Komik seru yang sayang untuk dilewatkan. Mulailah membaca dan rasakan sendiri petualangannya!';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final comic = widget.comic;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar / Hero Cover ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: comic.color,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() => _isBookmarked = !_isBookmarked);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isBookmarked
                            ? '${comic.title} ditambahkan ke bookmark'
                            : '${comic.title} dihapus dari bookmark',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined,
                      color: Colors.white, size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bagikan ${comic.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: comic.color,
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Icon(
                        Icons.menu_book,
                        size: 300,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Cover icon (center)
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.3),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              comic.genre,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comic.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                comic.rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.library_books_outlined,
                                  size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                comic.chapter,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
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
          ),

          // ─── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mulai baca ${comic.title}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Mulai Baca'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isBookmarked = !_isBookmarked);
                          },
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                          ),
                          label: Text(
                              _isBookmarked ? 'Tersimpan' : 'Simpan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: _isBookmarked
                                ? scheme.primary
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: comic.genre,
                        scheme: scheme,
                        cardColor: cardColor,
                      ),
                      _InfoChip(
                        icon: Icons.star_outline,
                        label: 'Rating ${comic.rating}',
                        scheme: scheme,
                        cardColor: cardColor,
                      ),
                      _InfoChip(
                        icon: Icons.menu_book_outlined,
                        label: comic.chapter,
                        scheme: scheme,
                        cardColor: cardColor,
                      ),
                      _InfoChip(
                        icon: Icons.check_circle_outline,
                        label: 'Ongoing',
                        scheme: scheme,
                        cardColor: cardColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sinopsis
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
                    text: _description,
                    scheme: scheme,
                  ),

                  const SizedBox(height: 24),

                  // Daftar Chapter Header
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
                        '${_chapters.length} chapter',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 13,
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ch = _chapters[index];
                return _ChapterTile(
                  chapter: ch,
                  comicColor: comic.color,
                  scheme: scheme,
                  cardColor: cardColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Membuka Chapter ${ch.number} - ${comic.title}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
              childCount: _chapters.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─── Helper classes ────────────────────────────────────────────────────────

class _ChapterItem {
  final int number;
  final String date;
  const _ChapterItem({required this.number, required this.date});
}

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
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
        ),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.scheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Lebih sedikit' : 'Selengkapnya',
            style: TextStyle(
              color: widget.scheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: comicColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${chapter.number}',
                    style: TextStyle(
                      color: comicColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${chapter.number}',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chapter.date,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
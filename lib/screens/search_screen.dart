import 'package:flutter/material.dart';
import '../models/comic.dart';
import '../widgets/comic_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  final List<String> _popularTags = [
    'Action',
    'Romance',
    'Fantasy',
    'Horror',
    'Sports',
    'Comedy',
  ];

  List<Comic> get _results {
    if (_query.isEmpty) return [];
    return dummyComics
        .where(
          (c) =>
              c.title.toLowerCase().contains(_query.toLowerCase()) ||
              c.genre.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEE);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Cari Komik',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => _query = val),
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari judul atau genre...',
                hintStyle: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onPressed: () => setState(() {
                          _query = '';
                          _controller.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _query.isEmpty
                ? _buildDiscover(scheme, surfaceVariant)
                : _buildResults(scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscover(ColorScheme scheme, Color surfaceVariant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Populer',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((tag) {
              return GestureDetector(
                onTap: () => setState(() {
                  _query = tag;
                  _controller.text = tag;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Trending',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...dummyComics.take(5).toList().asMap().entries.map((entry) {
            return _TrendingItem(rank: entry.key + 1, comic: entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildResults(ColorScheme scheme) {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "$_query"',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) => ComicCard(comic: _results[index]),
    );
  }
}

class _TrendingItem extends StatelessWidget {
  final int rank;
  final Comic comic;
  const _TrendingItem({required this.rank, required this.comic});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rank <= 3
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              color: comic.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.menu_book,
              size: 24,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comic.title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comic.genre,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    comic.rating,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comic.chapter,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

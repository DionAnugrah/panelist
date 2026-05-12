import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panelist/data/models/genres.dart';
import 'package:panelist/data/repositories/comic_repository_impl.dart';
import '../../data/models/comic.dart';
import '../../core/widgets/comic_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  // States
  String _query = '';
  String _selectedGenre = 'All Genres';
  String _selectedType = 'All Types';
  String _selectedStatus = 'All Status';

  List<Comic> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Options
  final List<String> _genreOptions = [
    'All Genres',
    ...genres.map((g) => g.name),
  ];
  final List<String> _typeOptions = ['All Types', 'Manga', 'Manhwa', 'Manhua'];
  final List<String> _statusOptions = ['All Status', 'Ongoing', 'Tamat'];

  // Fungsi tunggal untuk panggil API dengan params terkumpul
  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final repo = ComicRepositoryImpl();
      final results = await repo.searchComics(
        query: _query,
        genre: _selectedGenre,
        type: _selectedType,
        status: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _searchResults = results.comics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surfaceVariant = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEE);

    return SafeArea(
      child: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                _query = val;
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  _performSearch,
                );
              },
              decoration: InputDecoration(
                hintText: 'Cari komik...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDropdown(_selectedGenre, _genreOptions, (v) {
                  setState(() => _selectedGenre = v!);
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildDropdown(_selectedType, _typeOptions, (v) {
                  setState(() => _selectedType = v!);
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildDropdown(_selectedStatus, _statusOptions, (v) {
                  setState(() => _selectedStatus = v!);
                  _performSearch();
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty &&
                      _query.isEmpty &&
                      _selectedGenre == 'All Genres'
                ? const Center(
                    child: Text("Coba cari sesuatu atau pilih filter"),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.6,
                        ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) =>
                        ComicCard(comic: _searchResults[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panelist/data/models/comic_respone.dart';
import 'package:panelist/data/models/genres.dart';
import 'package:panelist/data/models/page_locator.dart';
import 'package:panelist/data/repositories/comic_repository_impl.dart';
import '../../data/models/comic.dart';
import '../../core/widgets/comic_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedGenre = 'All';
  List<Comic> comics = [];
  List<Comic> featuredComics =
      []; // Data khusus banner agar tidak hilang saat filter
  bool isLoading = true;
  PageLocator pageLocator = PageLocator();

  // Mengambil list genre dari file model/genres.dart
  final List<String> _genres = genres.map((g) => g.name).toList()
    ..insert(0, 'All');

  @override
  void initState() {
    super.initState();
    _initialFetch();
  }

  // Fetch pertama kali saat buka app
  Future<void> _initialFetch() async {
    final repo = ComicRepositoryImpl();
    try {
      final data = await repo.fetchComics();
      if (mounted) {
        setState(() {
          featuredComics = data.comics
              .take(5)
              .toList(); // Simpan 5 untuk banner
          comics = data.comics;
          pageLocator = PageLocator(
            currentPage: data.nextPage != null
                ? data.nextPage! - 1
                : data.prevPage != null
                ? data.prevPage! + 1
                : 1,
            nextPage: data.nextPage,
            prevPage: data.prevPage,
          );
          isLoading = false;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  // Dipanggil setiap kali genre diklik (Load Data Baru dari API)
  Future<void> _loadDataByGenre(String genre, {int page = 1}) async {
    setState(() => isLoading = true);

    final repo = ComicRepositoryImpl();
    try {
      ComicRespone data;
      if (genre == 'All') {
        data = await repo.fetchComics(page: page);
      } else {
        // Memanggil endpoint: /?genre=nama_genre
        data = await repo.fetchComicsByGenres(genre.toLowerCase(), page: page);
      }

      if (mounted) {
        setState(() {
          comics = data.comics;
          pageLocator = PageLocator(
            currentPage: data.nextPage != null
                ? data.nextPage! - 1
                : data.prevPage != null
                ? data.prevPage! + 1
                : 1,
            nextPage: data.nextPage,
            prevPage: data.prevPage,
          );
          isLoading = false;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    debugPrint("Error Fetching: $e");
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data dari server $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEE);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PaneList',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome, ${user?.email}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Banner (Selalu tampil dari featuredComics)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: featuredComics.isEmpty
                    ? const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _FeaturedCarousel(comics: featuredComics),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Genre Filter
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Genre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _genres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final genre = _genres[index];
                        final isSelected = genre == _selectedGenre;
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) return;
                            setState(() => _selectedGenre = genre);
                            _loadDataByGenre(genre); // Request API baru
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? scheme.primary
                                  : surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              genre,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : scheme.onSurface.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedGenre == 'All'
                          ? 'Semua Komik'
                          : 'Genre: $_selectedGenre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isLoading)
                      Text(
                        '${comics.length} komik',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Grid Content (Menangani Loading & Data Kosong)
            isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : comics.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(child: Text("Tidak ada komik ditemukan")),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ComicCard(comic: comics[index]),
                        childCount: comics.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.6,
                          ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Tombol Previous
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pageLocator.prevPage == null
                            ? null // Button mati jika tidak ada url prev
                            : () => _loadDataByGenre(
                                _selectedGenre,
                                page: pageLocator.prevPage!,
                              ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                        ),
                        label: const Text("Prev"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      pageLocator.currentPage != null
                          ? '${pageLocator.currentPage}'
                          : '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Tombol Next
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: pageLocator.nextPage == null
                            ? null // Button mati jika tidak ada url next
                            : () => _loadDataByGenre(
                                _selectedGenre,
                                page: pageLocator.nextPage!,
                              ),
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                        label: const Text('Next'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET CAROUSEL
class _FeaturedCarousel extends StatefulWidget {
  final List<Comic> comics;
  const _FeaturedCarousel({required this.comics});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.comics.isEmpty) return;
      final next = (_currentPage + 1) % widget.comics.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.comics.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final comic = widget.comics[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: scheme.primaryContainer, // Backup jika tidak ada image
                  image: DecorationImage(
                    image: NetworkImage(comic.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Tambahkan Image.network jika ada URL cover di model
                    const Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        Icons.menu_book,
                        size: 140,
                        color: Colors.white10,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(
                                0.8,
                              ), // Semakin ke bawah semakin gelap
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            comic.title,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comic.latestChapter,
                            style:  TextStyle(
                              color: const Color(0xFFE53935),
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.comics.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _currentPage ? scheme.primary : Colors.grey,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

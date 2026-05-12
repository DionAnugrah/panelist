import 'package:flutter/material.dart';
import 'package:panelist/data/models/comic.dart';
import 'package:panelist/data/repositories/comic_repository_impl.dart';
import 'package:panelist/features/profile/histori_service.dart';
import 'package:panelist/features/reader/data/chapter_detail.dart';

class BacaKomikScreen extends StatefulWidget {
  final String chapterParam;
  final String chapterTitle;
  final Comic comic;

  const BacaKomikScreen({
    super.key,
    required this.chapterParam,
    required this.chapterTitle,
    required this.comic,
  });

  @override
  State<BacaKomikScreen> createState() => _BacaKomikScreenState();
}

class _BacaKomikScreenState extends State<BacaKomikScreen> {
  ChapterDetail? _chapterDetail;

  bool _isLoading = true;
  bool _showAppBar = true;
  bool _isNavigating = false;

  late ScrollController _scrollController;

  double _overscrollOffset = 0;
  bool _isNextDirection = true;

  final double _triggerDistance = 180;
  final double _indicatorThreshold = 180;

  @override
  void initState() {
    setNewHistory();
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _fetchChapterImages();
  }

  void setNewHistory() {
    final historyService = HistoryService();

    historyService.saveHistory(
      param: widget.comic.param,
      title: widget.comic.title,
      thumbnail: widget.comic.thumbnail,
      lastChapter: widget.chapterTitle.split(' ').last,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);

    _scrollController.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    final pixels = position.pixels;
    final max = position.maxScrollExtent;
    final min = position.minScrollExtent;

    if (pixels > max) {
      setState(() {
        _isNextDirection = true;
        _overscrollOffset = pixels - max;
      });

      if (_overscrollOffset >= _triggerDistance) {
        _navigateToChapter(isNext: true);
      }
    } else if (pixels < min) {
      setState(() {
        _isNextDirection = false;
        _overscrollOffset = (min - pixels);
      });

      if (_overscrollOffset >= _triggerDistance) {
        _navigateToChapter(isNext: false);
      }
    } else {
      if (_overscrollOffset != 0) {
        setState(() {
          _overscrollOffset = 0;
        });
      }
    }
  }

  void _navigateToChapter({required bool isNext}) {
    if (_isNavigating) return;

    _isNavigating = true;

    final match = RegExp(r'chapter-(\d+)').firstMatch(widget.chapterParam);

    if (match == null) {
      _isNavigating = false;
      return;
    }

    final currentText = match.group(1)!;

    final currentNum = int.parse(currentText);

    final targetNum = isNext ? currentNum + 1 : currentNum - 1;

    if (targetNum < 1) {
      _isNavigating = false;

      _showSnackBar("Ini adalah chapter pertama");

      return;
    }

    final paddedTarget = targetNum.toString().padLeft(currentText.length, '0');

    final newParam = widget.chapterParam.replaceFirst(
      currentText,
      paddedTarget,
    );

    final newTitle = "Chapter $targetNum";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BacaKomikScreen(
          chapterParam: newParam,
          chapterTitle: newTitle,
          comic: widget.comic,
        ),
      ),
    );
  }

  Future<void> _fetchChapterImages() async {
    final repo = ComicRepositoryImpl();

    try {
      final data = await repo.fetchChapterDetail(widget.chapterParam);

      if (!mounted) return;

      setState(() {
        _chapterDetail = data;
        _isLoading = false;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal memuat: $e')));
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      extendBodyBehindAppBar: true,

      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),

              elevation: 0,

              title: Text(
                widget.chapterTitle,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),

              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          : null,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _chapterDetail == null || _chapterDetail!.imageUrls.isEmpty
          ? _buildEmptyState()
          : Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAppBar = !_showAppBar;
                    });
                  },

                  child: ListView.builder(
                    controller: _scrollController,

                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),

                    padding: EdgeInsets.zero,

                    itemCount: _chapterDetail!.imageUrls.length,

                    itemBuilder: (context, index) {
                      return Image.network(
                        _chapterDetail!.imageUrls[index],

                        fit: BoxFit.contain,

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            height: 400,
                            color: Colors.black,

                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },

                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 200,
                            color: Colors.grey[900],

                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_overscrollOffset > 10) _buildNavigationIndicator(),
              ],
            ),
    );
  }

  Widget _buildNavigationIndicator() {
    final progress = (_overscrollOffset / _indicatorThreshold).clamp(0.0, 1.0);

    final ready = _overscrollOffset >= _triggerDistance;

    return Positioned(
      top: !_isNextDirection ? 100 : null,

      bottom: _isNextDirection ? 60 : null,

      left: 0,
      right: 0,

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Stack(
              alignment: Alignment.center,

              children: [
                SizedBox(
                  width: 50,
                  height: 50,

                  child: CircularProgressIndicator(
                    value: progress,

                    strokeWidth: 4,

                    backgroundColor: Colors.white10,

                    color: ready ? Colors.greenAccent : Colors.white,
                  ),
                ),

                Icon(
                  _isNextDirection ? Icons.arrow_downward : Icons.arrow_upward,

                  color: ready ? Colors.greenAccent : Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              decoration: BoxDecoration(
                color: Colors.black87,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: ready ? Colors.greenAccent : Colors.white24,
                ),
              ),

              child: Text(
                ready
                    ? "Lepas untuk ke ${_isNextDirection ? 'Chapter Selanjutnya' : 'Chapter Sebelumnya'}"
                    : "Tarik untuk ${_isNextDirection ? 'Next' : 'Prev'}",

                style: TextStyle(
                  color: ready ? Colors.greenAccent : Colors.white,

                  fontSize: 12,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Gambar tidak tersedia.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

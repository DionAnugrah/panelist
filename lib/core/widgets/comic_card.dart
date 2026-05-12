import 'package:flutter/material.dart';
import '../../data/models/comic.dart';

class ComicCard extends StatelessWidget {
  final Comic comic;
  const ComicCard({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(comic.thumbnail),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // child: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     const Icon(Icons.star, size: 10, color: Colors.amber),
                      //     const SizedBox(width: 2),
                      //     Text(
                      //       comic.rating,
                      //       style: const TextStyle(
                      //         fontSize: 10,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comic.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comic.latestChapter,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

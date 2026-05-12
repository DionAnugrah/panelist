// import 'package:flutter/material.dart';
// import '../../data/models/comic.dart';
// import '../../core/widgets/comic_card.dart';

// class BookmarkScreen extends StatefulWidget {
//   const BookmarkScreen({super.key});

//   @override
//   State<BookmarkScreen> createState() => _BookmarkScreenState();
// }

// class _BookmarkScreenState extends State<BookmarkScreen> {
//   int _viewMode = 0;

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;

//     return SafeArea(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Bookmark',
//                   style: TextStyle(
//                     color: scheme.onSurface,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.grid_view,
//                         color: _viewMode == 0
//                             ? scheme.primary
//                             : scheme.onSurface.withValues(alpha: 0.4),
//                       ),
//                       onPressed: () => setState(() => _viewMode = 0),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.view_list,
//                         color: _viewMode == 1
//                             ? scheme.primary
//                             : scheme.onSurface.withValues(alpha: 0.4),
//                       ),
//                       onPressed: () => setState(() => _viewMode = 1),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               '${bookmarkedComics.length} komik tersimpan',
//               style: TextStyle(
//                 color: scheme.onSurface.withValues(alpha: 0.4),
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: bookmarkedComics.isEmpty
//                 ? _buildEmpty(scheme)
//                 : _viewMode == 0
//                 ? _buildGrid()
//                 : _buildList(scheme),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.6,
//       ),
//       itemCount: bookmarkedComics.length,
//       itemBuilder: (context, index) =>
//           ComicCard(comic: bookmarkedComics[index]),
//     );
//   }

//   Widget _buildList(ColorScheme scheme) {
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: bookmarkedComics.length,
//       separatorBuilder: (_, _) => const SizedBox(height: 10),
//       itemBuilder: (context, index) {
//         final comic = bookmarkedComics[index];
//         final cardColor = Theme.of(context).cardColor;

//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: cardColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 60,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: comic.color,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.menu_book,
//                   size: 28,
//                   color: Colors.white.withValues(alpha: 0.4),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       comic.title,
//                       style: TextStyle(
//                         color: scheme.onSurface,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       comic.genre,
//                       style: TextStyle(
//                         color: scheme.onSurface.withValues(alpha: 0.5),
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.star, size: 13, color: Colors.amber),
//                         const SizedBox(width: 4),
//                         Text(
//                           comic.rating,
//                           style: TextStyle(
//                             color: scheme.onSurface.withValues(alpha: 0.7),
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: scheme.onSurface.withValues(alpha: 0.08),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             comic.chapter,
//                             style: TextStyle(
//                               color: scheme.onSurface.withValues(alpha: 0.5),
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.bookmark, color: scheme.primary, size: 22),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmpty(ColorScheme scheme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.bookmark_outline,
//             size: 72,
//             color: scheme.onSurface.withValues(alpha: 0.2),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Belum ada bookmark',
//             style: TextStyle(
//               color: scheme.onSurface.withValues(alpha: 0.5),
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tambahkan komik favoritmu di sini',
//             style: TextStyle(
//               color: scheme.onSurface.withValues(alpha: 0.3),
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

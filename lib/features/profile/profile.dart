import 'package:flutter/material.dart';
import 'package:panelist/data/models/comic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../../core/widgets/comic_card.dart';
import 'histori_service.dart';
import '../library/bookmark_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Pengguna';
    final username = email.split('@').first;
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Theme Toggle
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (_, mode, _) {
                              return IconButton(
                                icon: Icon(
                                  mode == ThemeMode.dark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: scheme.onSurface,
                                ),
                                onPressed: () {
                                  themeNotifier.value = mode == ThemeMode.dark
                                      ? ThemeMode.light
                                      : ThemeMode.dark;
                                },
                              );
                            },
                          ),
                          // Settings
                          IconButton(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: scheme.onSurface,
                            ),
                            onPressed: () => _showSettings(context, scheme),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: scheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF121212)
                                : const Color(0xFFF5F5F5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Username
                Text(
                  username,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: scheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'Riwayat Baca'),
                      Tab(text: 'Favorit'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Riwayat Baca
            FutureBuilder<List<dynamic>>(
              future: HistoryService().fetchHistory(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                final comics = data
                    .map((item) => Comic.fromJson(item))
                    .toList();

                return _ComicTabContent(
                  comics: comics,
                  emptyMessage: 'Belum ada riwayat baca',
                  emptyIcon: Icons.history,
                );
              },
            ),

            // Tab 2: Favorit (Bookmark)
            FutureBuilder<List<Comic>>(
              future: BookmarkService().fetchBookmarks(),
              builder: (context, snapshot) {
                final comics = snapshot.data ?? [];

                return _ComicTabContent(
                  comics: comics,
                  emptyMessage: 'Belum ada favorit',
                  emptyIcon: Icons.favorite_outline,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profil',
                scheme: scheme,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur segera hadir')),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                scheme: scheme,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur segera hadir')),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                label: 'Bantuan',
                scheme: scheme,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur segera hadir')),
                  );
                },
              ),
              const Divider(height: 8),
              _SettingsTile(
                icon: Icons.logout,
                label: 'Keluar',
                scheme: scheme,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? scheme.error : scheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}

class _ComicTabContent extends StatelessWidget {
  final List<Comic> comics;
  final String emptyMessage;
  final IconData emptyIcon;

  const _ComicTabContent({
    required this.comics,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (comics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: comics.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          // onTap: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => InfoKomikScreen(comic: comics[index]),
          //   ),
          // ),
          child: ComicCard(
            comic: Comic(
              title: comics[index].title,
              description: comics[index].description,
              latestChapter: 'Last Read: ${comics[index].latestChapter}',
              thumbnail: comics[index].thumbnail,
              param: comics[index].param,
              detailUrl: comics[index].detailUrl,
            ),
          ),
        );
      },
    );
  }
}

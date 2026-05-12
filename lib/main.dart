import 'package:flutter/material.dart';
import 'package:panelist/features/profile/profile.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/library/bookmark_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_config.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_gate.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const ComicApp());
}

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'PaneList',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const AuthGate(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    // BookmarkScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: scheme.onPrimary);
            }
            return IconThemeData(color: scheme.onSurfaceVariant);
          }),
        ),
        child: NavigationBar(
          backgroundColor: cardColor,
          indicatorColor: scheme.primary,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Bookmark',
            ),

            NavigationDestination(
              // ← Ditambahkan
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

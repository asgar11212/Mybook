import 'package:flutter/material.dart';
import 'package:notscrd/screens/gen_screen.dart';
import 'package:notscrd/screens/home.dart';
import 'package:notscrd/screens/settings.dart';
import 'add_book_screen.dart';

class MainNavScreen extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;

  const MainNavScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const AddBookScreen(),
      const GenresScreen(),
      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _keyboardIsVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = _keyboardIsVisible(context);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: !keyboardVisible
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BottomNavigationBar(
                  backgroundColor: Theme.of(context).cardColor,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.grey,
                  currentIndex: _selectedIndex,
                  onTap: _onTabSelected,
                  elevation: 8,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_books),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category),
                      label: 'Genres',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

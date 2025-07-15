import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notscrd/data_base/book_database.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _localDarkMode;

  String _currentSort = 'title';

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.isDarkMode;
    _loadSortPreference();
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentSort = prefs.getString('sortOrder') ?? 'title';
    });
  }

  Future<void> _clearAllBooks(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to delete all books?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BookDatabase.instance.clearAllBooks();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("All books deleted.")));
      }
    }
  }

  Future<void> _showSortOptions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        String selected = _currentSort;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text("Title (A–Z)"),
                  selected: selected == 'title',
                  onTap: () async {
                    await prefs.setString('sortOrder', 'title');
                    setModalState(() => selected = 'title');
                    setState(() => _currentSort = 'title');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text("Recently Added"),
                  selected: selected == 'recent',
                  onTap: () async {
                    await prefs.setString('sortOrder', 'recent');
                    setModalState(() => selected = 'recent');
                    setState(() => _currentSort = 'recent');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.done),
                  title: const Text("Read First"),
                  selected: selected == 'read',
                  onTap: () async {
                    await prefs.setString('sortOrder', 'read');
                    setModalState(() => selected = 'read');
                    setState(() => _currentSort = 'read');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _sortLabel(String sortKey) {
    switch (sortKey) {
      case 'title':
        return 'Title (A–Z)';
      case 'recent':
        return 'Recently Added';
      case 'read':
        return 'Read First';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Fixed: Dark mode toggle (local + global update)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile.adaptive(
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.dark_mode),
              value: _localDarkMode,
              onChanged: (newValue) {
                setState(() {
                  _localDarkMode = newValue;
                });
                widget.onThemeToggle(newValue); // 🔁 Notify parent
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Sort books
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: const Text("Sort Books"),
              subtitle: Text("Current: ${_sortLabel(_currentSort)}"),
              onTap: () => _showSortOptions(context),
            ),
          ),

          const SizedBox(height: 16),

          // Clear all books
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Clear All Books"),
              onTap: () => _clearAllBooks(context),
            ),
          ),

          const SizedBox(height: 16),

          // App Info
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("App Version"),
              subtitle: Text("1.0.0"),
            ),
          ),
        ],
      ),
    );
  }
}

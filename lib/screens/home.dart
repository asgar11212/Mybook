import 'package:flutter/material.dart';
import 'package:notscrd/data_base/book_database.dart';
import 'package:notscrd/widgets/book_items.dart';
import '../models/book.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Book>> _books;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _books = BookDatabase.instance.getAllBooks();
    });
  }

  void _navigateToAddBook() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (result == true) {
      _loadBooks();
    }
  }

  void _navigateToEditBook(Book book) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
    );
    if (result == true) {
      _loadBooks();
    }
  }

  void _deleteBook(int id) async {
    await BookDatabase.instance.deleteBook(id);
    _loadBooks();
  }

  List<Book> _filterBooks(List<Book> books) {
    final filtered = books.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_sortOrder == 'A-Z') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortOrder == 'Z-A') {
      filtered.sort((a, b) => b.title.compareTo(a.title));
    } else if (_sortOrder == 'Newest') {
      filtered.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    }

    switch (_selectedTabIndex) {
      case 1:
        return filtered.where((b) => b.isRead).toList();
      case 2:
        return filtered.where((b) => !b.isRead).toList();
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyBooks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBooks,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color.fromARGB(255, 46, 46, 46),
          unselectedLabelColor: Colors.white,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Read'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _sortOrder,
                    underline: const SizedBox(),
                    items: ['A-Z', 'Z-A', 'Newest'].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortOrder = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Book>>(
              future: _books,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final all = snapshot.data!;
                  final read = all.where((b) => b.isRead).length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '📚 You’ve read $read of ${all.length} books',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: _books,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  } else {
                    final filteredBooks = _filterBooks(snapshot.data!);
                    if (filteredBooks.isEmpty) return _buildEmptyState(context);

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredBooks.length,
                      itemBuilder: (ctx, index) {
                        return BookItem(
                          book: filteredBooks[index],
                          onTap: () =>
                              _navigateToEditBook(filteredBooks[index]),
                          onDelete: () => _deleteBook(filteredBooks[index].id!),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 80, color: colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'No books yet!',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start building your reading list by adding a new book.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Book'),
              onPressed: _navigateToAddBook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

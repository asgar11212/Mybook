import 'package:flutter/material.dart';
import 'package:notscrd/data_base/book_database.dart';
import '../models/book.dart';
import 'edit_book_screen.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _booksFuture = BookDatabase.instance.getAllBooks();
    });
  }

  Future<void> _refreshBooks() async {
    await _loadBooks();
  }

  Map<String, List<Book>> _groupByGenre(List<Book> books) {
    final Map<String, List<Book>> genreMap = {};
    for (var book in books) {
      for (var genre in book.genres) {
        if (!genreMap.containsKey(genre)) {
          genreMap[genre] = [];
        }
        genreMap[genre]!.add(book);
      }
    }
    return genreMap;
  }

  void _navigateToEdit(Book book) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
    );
    if (result == true) {
      _refreshBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books by Genre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshBooks,
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          } else {
            final genreMap = _groupByGenre(snapshot.data!);
            if (genreMap.isEmpty) {
              return const Center(child: Text('No genres assigned.'));
            }

            return RefreshIndicator(
              onRefresh: _refreshBooks,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: genreMap.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: entry.value.map((book) {
                      return ListTile(
                        title: Text(book.title),
                        subtitle: Text(book.author ?? 'No author'),
                        trailing: Icon(
                          book.isRead ? Icons.check_circle : Icons.circle,
                          color: book.isRead ? Colors.green : Colors.grey,
                        ),
                        onTap: () => _navigateToEdit(book),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

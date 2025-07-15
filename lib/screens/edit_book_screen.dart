import 'package:flutter/material.dart';
import 'package:notscrd/data_base/book_database.dart';
import '../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _notesController;
  late bool _isRead;
  List<String> _selectedGenres = [];

  final List<String> _availableGenres = [
    'Fiction',
    'Non-fiction',
    'Philosophy',
    'Science',
    'Fantasy',
    'History',
    'Biography',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _notesController = TextEditingController(text: widget.book.notes);
    _isRead = widget.book.isRead;
    _selectedGenres = widget.book.genres ?? [];
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final updatedBook = Book(
        id: widget.book.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        notes: _notesController.text.trim(),
        isRead: _isRead,
        genres: _selectedGenres,
      );

      await BookDatabase.instance.updateBook(updatedBook);

      // Go back
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 🔘 Genres
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Genres',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableGenres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (_) => _toggleGenre(genre),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              SwitchListTile.adaptive(
                title: const Text('Mark as Read'),
                value: _isRead,
                onChanged: (value) {
                  setState(() => _isRead = value);
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateBook,
                  icon: const Icon(Icons.save),
                  label: const Text('Update Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

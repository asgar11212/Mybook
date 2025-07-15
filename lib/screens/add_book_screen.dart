import 'package:flutter/material.dart';
import 'package:notscrd/data_base/book_database.dart';
import '../models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isRead = false;
  final List<String> _selectedGenres = [];

  final List<String> _availableGenres = [
    'Fiction',
    'Mystery',
    'Romance',
    'Self-Help',
    'Fantasy',
    'Sci-Fi',
    'Biography',
    'Philosophy',
    'History',
  ];

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        notes: _notesController.text.trim(),
        isRead: _isRead,
        genres: _selectedGenres,
      );

      await BookDatabase.instance.addBook(newBook);

      // Clear and navigate
      _formKey.currentState!.reset();
      _titleController.clear();
      _authorController.clear();
      _notesController.clear();
      _selectedGenres.clear();
      setState(() => _isRead = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                title: const Text('Mark as Read'),
                value: _isRead,
                onChanged: (val) => setState(() => _isRead = val),
              ),
              const SizedBox(height: 20),
              const Text('Select Genres:'),
              Wrap(
                spacing: 8.0,
                children: _availableGenres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(genre);
                        } else {
                          _selectedGenres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Book'),
                  onPressed: _saveBook,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

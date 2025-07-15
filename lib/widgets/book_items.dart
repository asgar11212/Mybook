import 'package:flutter/material.dart';
import '../models/book.dart';

class BookItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookItem({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(book.author ?? 'Unknown Author'),
        leading: Icon(
          book.isRead ? Icons.check_circle : Icons.menu_book,
          color: book.isRead ? Colors.green : Colors.grey,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

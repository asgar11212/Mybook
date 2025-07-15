import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final String? author;
  final String? notes;
  final bool isRead;
  final List<String> genres;

  Book({
    this.id,
    required this.title,
    this.author,
    this.notes,
    required this.isRead,
    this.genres = const [],
  });

  /// Convert Book object to a map for saving to SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'notes': notes,
      'isRead': isRead ? 1 : 0,
      'genres': jsonEncode(genres), // Convert list to JSON string
    };
  }

  /// Create Book object from map retrieved from SQLite
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'] ?? '',
      author: map['author'],
      notes: map['notes'],
      isRead: map['isRead'] == 1,
      genres: _decodeGenres(map['genres']),
    );
  }

  /// Decode genres safely from dynamic input
  static List<String> _decodeGenres(dynamic genresField) {
    if (genresField is String && genresField.isNotEmpty) {
      try {
        final decoded = jsonDecode(genresField);
        if (decoded is List) {
          return List<String>.from(decoded.map((e) => e.toString()));
        }
      } catch (e) {
        // If JSON is malformed or decoding fails
        return [];
      }
    }
    return [];
  }
}

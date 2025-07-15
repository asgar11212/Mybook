import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class BookDatabase {
  static final BookDatabase instance = BookDatabase._init();

  static Database? _database;

  BookDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS books');
        await _createDB(db, newVersion);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        notes TEXT,
        isRead INTEGER NOT NULL,
        genres TEXT
      )
    ''');
  }

  Future<void> addBook(Book book) async {
    final db = await instance.database;
    await db.insert('books', book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await instance.database;
    final result = await db.query('books');
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<void> updateBook(Book book) async {
    final db = await instance.database;
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<void> deleteBook(int id) async {
    final db = await instance.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearAllBooks() async {
    final db = await instance.database;
    await db.delete('books');
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';

class StorageService {
  static const String booksKey = "books";

  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(booksKey);

    if (jsonString == null) {
      return [];
    }

    final List decoded = jsonDecode(jsonString);

    return decoded.map((e) => Book.fromJson(e)).toList();
  }

  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(books.map((e) => e.toJson()).toList());

    await prefs.setString(booksKey, jsonString);
  }

  static Future<void> addBook(Book book) async {
    final books = await loadBooks();

    books.add(book);

    await saveBooks(books);
  }
}
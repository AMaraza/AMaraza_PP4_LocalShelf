import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'book.dart';
import 'storage_service.dart';

class BrowseBooksView extends StatefulWidget {
  const BrowseBooksView({super.key});

  @override
  State<BrowseBooksView> createState() => _BrowseBooksViewState();
}

class _BrowseBooksViewState extends State<BrowseBooksView> {
  final TextEditingController searchController = TextEditingController();

  String? title;
  String? author;
  String? coverUrl;
  int? coverId;

  String selectedShelf = "WishList";

  bool searched = false;
  bool isLoading = false;
  bool isSaving = false;
  bool bookFound = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchBook() async {
    final searchText = searchController.text.trim();

    if (searchText.isEmpty) return;

    setState(() {
      isLoading = true;
      searched = true;
      bookFound = false;

      title = null;
      author = null;
      coverUrl = null;
      coverId = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://openlibrary.org/search.json?title=${Uri.encodeComponent(searchText)}&limit=1",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["docs"] != null && data["docs"].isNotEmpty) {
          final book = data["docs"][0];

          setState(() {
            title = book["title"] ?? "Unknown Title";

            author = book["author_name"] != null
                ? book["author_name"][0]
                : "Unknown Author";

            if (book["cover_i"] != null) {
              coverId = book["cover_i"];
              coverUrl =
                  "https://covers.openlibrary.org/b/id/$coverId-M.jpg";
            }

            bookFound = true;
          });
        }
      }
    } catch (_) {
      bookFound = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveBook() async {
    if (!bookFound) return;

    setState(() {
      isSaving = true;
    });

    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title!,
      author: author!,
      coverId: coverId,
      shelf: selectedShelf,
      dateAdded: DateTime.now(),
    );

    await StorageService.addBook(book);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Book saved successfully!"),
      ),
    );
  }

  Widget buildBookDisplay() {
    if (!searched) {
      return const SizedBox();
    }

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (!bookFound) {
      return const Column(
        children: [
          Icon(Icons.menu_book, size: 120),
          SizedBox(height: 10),
          Text(
            "Book Not Found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "No matching book was found.",
          ),
        ],
      );
    }

    return Column(
      children: [
        coverUrl != null
            ? Image.network(
                coverUrl!,
                height: 180,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.menu_book, size: 120),
              )
            : const Icon(Icons.menu_book, size: 120),

        const SizedBox(height: 12),

        Text(
          title!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          author!,
          style: const TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 16),

        DropdownButton<String>(
          value: selectedShelf,
          items: const [
            DropdownMenuItem(
              value: "WishList",
              child: Text("WishList"),
            ),
            DropdownMenuItem(
              value: "To Be Read",
              child: Text("To Be Read"),
            ),
            DropdownMenuItem(
              value: "Finished",
              child: Text("Finished"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedShelf = value!;
            });
          },
        ),

        const SizedBox(height: 15),

        ElevatedButton.icon(
          onPressed: isSaving ? null : saveBook,
          icon: const Icon(Icons.save),
          label: Text(
            isSaving ? "Saving..." : "Save Book",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Books"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: "Search for a book",
                    hintText: "e.g. Lord of the Rings",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: searchBook,
                  child: const Text("Search"),
                ),

                const SizedBox(height: 24),

                buildBookDisplay(),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Return"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
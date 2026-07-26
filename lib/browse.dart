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

  List<Map<String, dynamic>> searchResults = [];

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
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://openlibrary.org/search.json?title=${Uri.encodeComponent(searchText)}&limit=4",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          searchResults.clear();

          if (data["docs"] != null) {
            for (final book in data["docs"].take(4)) {
              searchResults.add({
                "title": book["title"] ?? "Unknown Title",
                "author": book["author_name"] != null
                    ? book["author_name"][0]
                    : "Unknown Author",
                "coverId": book["cover_i"],
              });
            }
          }
        });
        }
      }
      catch (_) {
        setState(() {
          searchResults.clear();
        });
      }

    setState(() {
      isLoading = false;
    });
  }

  /*Future<void> saveBook() async {
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
  }*/

Widget buildBookDisplay() {
  if (!searched) {
    return const SizedBox();
  }

  if (isLoading) {
    return const CircularProgressIndicator();
  }

  if (searchResults.isEmpty) {
    return const Column(
      children: [
        Icon(Icons.menu_book, size: 120),
        SizedBox(height: 10),
        Text(
          "No Books Found",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: searchResults.length,
    itemBuilder: (context, index) {
      final book = searchResults[index];

      final coverUrl = book["coverId"] != null
          ? "https://covers.openlibrary.org/b/id/${book["coverId"]}-M.jpg"
          : null;

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              coverUrl != null
                  ? Image.network(
                      coverUrl,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(
                      width: 80,
                      height: 120,
                      child: Icon(Icons.menu_book),
                    ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book["title"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(book["author"]),

                    const SizedBox(height: 12),

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

                    ElevatedButton.icon(
                      onPressed: () {
                        // We'll hook this back up to save later
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
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
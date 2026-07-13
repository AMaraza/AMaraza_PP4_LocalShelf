import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:firebase_database/firebase_database.dart';

class BrowseBooksView extends StatefulWidget {
  const BrowseBooksView({super.key});

  @override
  State<BrowseBooksView> createState() => _BrowseBooksViewState();
}

/*Future<void> fetchData() async {

  final response = await http.get(
    Uri.parse('https://openlibrary.org/search.json?title=project+hail+mary'),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data['docs'][0]['title']);
  } else {
    throw Exception('Failed to load data');
  }
}

final database = FirebaseDatabase.instance.ref();

Future<void> writeTestBook() async {
  await database.child("books/testBook").set({
    "title": "The Hunger Games",
    "author": "Suzanne Collins",
  });

  print("Book written to Firebase");
}*/

class _BrowseBooksViewState extends State<BrowseBooksView> {
  final TextEditingController searchController = TextEditingController();
  //final database = FirebaseDatabase.instance.ref();

  String? title;
  String? author;
  String? coverUrl;
  String selectedShelf = "Want to Read";
  
  bool searched = false;
  bool isLoading = false;
  bool bookFound = false;

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
    });

    try {
       final response = await http.get(
        Uri.parse(
          'https://openlibrary.org/search.json?title=${Uri.encodeComponent(searchText)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['docs'] != null && data['docs'].isNotEmpty) {
          final book = data['docs'][0];

          setState(() {
            title = book['title'] ?? "Unknown Title";
            author = book['author_name'] != null ? book['author_name'][0] : "Unknown Author";

            if (book['cover_i'] != null) {
              coverUrl =
                  'https://covers.openlibrary.org/b/id/${book['cover_i']}-M.jpg';
            }

            bookFound = true;
          });
        }
      }
    } catch(e) {
      bookFound = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildBookDisplay() {
    if (!searched) return const SizedBox();

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (!bookFound) {
      return Column(
        children: const [
          Icon(Icons.menu_book, size: 120),
          SizedBox(height: 10),
          Text(
            "Book Not Found",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text("No matching book was found or the API request failed."),
        ],
      );
    }

    return Column(
      children: [
        coverUrl != null
            ? Image.network(
                coverUrl!,
                height: 180,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.menu_book, size: 120);
                },
              )
            : const Icon(Icons.menu_book, size: 120),

        const SizedBox(height: 12),

        Text(
          title!,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
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
              value: "Want to Read",
              child: Text("Want to Read"),
            ),
            DropdownMenuItem(
              value: "Currently Reading",
              child: Text("Currently Reading"),
            ),
            DropdownMenuItem(
              value: "Read",
              child: Text("Read"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedShelf = value!;
            });
          },
        ),

        /*extButton(
          onPressed: saveBook,
          child: const Text("Save Book"),
        ),*/
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              TextButton(
                onPressed: searchBook,
                child: const Text("Search API"),
                ),

              const SizedBox(height: 20),

              buildBookDisplay(),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Return"),
              )
            ],
          )
        )
      ))
    );
  }
}
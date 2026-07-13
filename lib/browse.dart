import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';


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
  String? coverId;

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
      coverId = null;
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

            author = book['author_name'] != null
                ? book['author_name'][0]
                : "Unknown Author";


            if (book['cover_i'] != null) {

              coverId = book['cover_i'].toString();

              coverUrl =
                  'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

            }


            bookFound = true;
          });

        }
      }

    } catch (e) {

      setState(() {
        bookFound = false;
      });

    }


    setState(() {
      isLoading = false;
    });
  }



Future<void> saveBook() async {
  if (!bookFound) return;

  try {
    await FirebaseFirestore.instance
        .collection('books')
        .add({
          "title": title,
          "author": author,
          "coverId": coverId,
          "shelf": selectedShelf,
          "dateAdded": Timestamp.now(),
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Book saved successfully"),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to save book: $e"),
      ),
    );

  }
}



  Widget buildBookDisplay() {

    if (!searched) {
      return const SizedBox();
    }


    if (isLoading) {

      return const CircularProgressIndicator();

    }



    if (!bookFound) {

      return Column(
        children: const [

          Icon(
            Icons.menu_book,
            size: 120,
          ),

          SizedBox(height: 10),

          Text(
            "Book Not Found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "No matching book was found or the API request failed.",
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
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.menu_book,
                    size: 120,
                  );
                },
              )
            : const Icon(
                Icons.menu_book,
                size: 120,
              ),
        const SizedBox(height: 12),
        Text(
          title!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        Text(
          author!,
          style: const TextStyle(
            fontSize: 18,
          ),
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
        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: saveBook,
          child: const Text("Save Book"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
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
            ),
          ),
        ),
      ),
    );
  }
}
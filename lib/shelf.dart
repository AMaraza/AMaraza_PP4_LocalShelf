import 'package:flutter/material.dart';

class ShelfView extends StatefulWidget {
  const ShelfView({super.key});

  @override
  State<ShelfView> createState() => _ShelfViewState();
}

class _ShelfViewState extends State<ShelfView> {
  final List<String> shelves = [
    "Wishlist",
    "To Be Read",
    "Finished",
  ];

  String selectedShelf = "Wishlist";
  String sortBy = "Date Added";

List<Map<String, dynamic>> books = [
  {
    "id": "1",
    "title": "Project Hail Mary",
    "author": "Andy Weir",
    "coverUrl": "https://covers.openlibrary.org/b/isbn/9780593135204-M.jpg",
    "shelf": "Wishlist",
    "dateAdded": 3,
  },
  {
    "id": "2",
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "coverUrl": "https://covers.openlibrary.org/b/isbn/9780547928227-M.jpg",
    "shelf": "To Be Read",
    "dateAdded": 2,
  },
  {
    "id": "3",
    "title": "The Hunger Games",
    "author": "Suzanne Collins",
    "coverUrl": "https://covers.openlibrary.org/b/isbn/9780439023481-M.jpg",
    "shelf": "Finished",
    "dateAdded": 1,
  },
];

  List<Map<String, dynamic>> get currentShelfBooks {
    List<Map<String, dynamic>> shelfBooks = books.where((book) => book["shelf"] == selectedShelf).toList();

    if (sortBy == "Title") {
      shelfBooks.sort((a, b) => a["title"].compareTo(b["title"]));
    } else if (sortBy == "Author") {
      shelfBooks.sort((a, b) => a["author"].compareTo(b["author"]));
    } else {
      shelfBooks.sort((a, b) => b["dateAdded"].compareTo(a["dateAdded"]));
    }

    return shelfBooks;
  }

  void deleteBook(String bookId) {
    setState(() {
      books.removeWhere((book) => book["id"] == bookId);
    });
  }

  void moveBook(String bookId, String newShelf) {
    setState(() {
      for (var book in books) {
        if (book["id"] == bookId) {
          book["shelf"] = newShelf;
        }
      }
    });
  }


  Widget buildShelfSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: shelves.map((shelf) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedShelf = shelf;
              });
            },
            child: Text(shelf),
          ),
        );
      }).toList(),
    );
  }
  
  Widget buildSortDropdown() {
    return DropdownButton<String>(
      value: sortBy,
      items: const [
        DropdownMenuItem(
          value: "Date Added",
          child: Text("Date Added"),
        ),
        DropdownMenuItem(
          value: "Title",
          child: Text("Title"),
        ),
        DropdownMenuItem(
          value: "Author",
          child: Text("Author"),
        ),
      ],
      onChanged: (value) {
        setState(() {
          sortBy = value!;
        });
      },
    );
  }

  Widget buildDeleteArea() {
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) {
        deleteBook(details.data["id"]);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 70,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          color: candidateData.isNotEmpty ? Colors.red[300] : Colors.red[100],
          child: const Center(
            child: Text(
              "Drag Here to Delete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget buildBookCard(Map<String, dynamic> book) {
    return Draggable<Map<String, dynamic>>(
      data: book,
      feedback: Material(
        child: buildBookVisual(book),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: buildBookVisual(book),
      ),
      child: buildBookVisual(book),
    );
  }

  Widget buildBookVisual(Map<String, dynamic> book) {
    return Card(
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            Image.network(
              book["coverUrl"],
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.menu_book, size: 80);
              },
            ),
            const SizedBox(height: 6),
            Text(
              book["title"],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book["author"],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            DropdownButton<String>(
              value: book["shelf"],
              items: shelves.map((shelf) {
                return DropdownMenuItem(
                  value: shelf,
                  child: Text(shelf),
                );
              }).toList(),
              onChanged: (value) {
                moveBook(book["id"], value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),

            Text(
              selectedShelf,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            buildShelfSelector(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sort by: "),
                buildSortDropdown(),
              ],
            ),

            buildDeleteArea(),

            Expanded(
              child: currentShelfBooks.isEmpty
                  ? const Center(child: Text("No books on this shelf yet."))
                  : GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 0.45,
                      children: currentShelfBooks.map((book) {
                        return buildBookCard(book);
                      }).toList(),
                    ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Return"),
            ),
          ],
        ),
      ),
    );
  }
}
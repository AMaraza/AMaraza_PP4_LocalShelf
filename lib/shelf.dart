import 'package:flutter/material.dart';

class ShelfView extends StatefulWidget {
  const ShelfView({super.key});

  @override
  State<ShelfView> createState() => _ShelfViewState();
}

class _ShelfViewState extends State<ShelfView> {
  final List<String> shelves = [
    "WishList",
    "To Be Read",
    "Finished",
  ];

  String selectedShelf = "WishList";
  String sortBy = "Custom";

  final List<Map<String, dynamic>> books = [
    {
      "id": "1",
      "title": "Project Hail Mary",
      "author": "Andy Weir",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780593135204-L.jpg",
      "shelf": "WishList",
      "dateAdded": 6,
      "order": 0,
    },
    {
      "id": "2",
      "title": "The Hobbit",
      "author": "J.R.R. Tolkien",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg",
      "shelf": "WishList",
      "dateAdded": 3,
      "order": 1,
    },
    {
      "id": "3",
      "title": "The Hunger Games",
      "author": "Suzanne Collins",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780439023481-L.jpg",
      "shelf": "WishList",
      "dateAdded": 5,
      "order": 2,
    },
    {
      "id": "4",
      "title": "Dune",
      "author": "Frank Herbert",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg",
      "shelf": "To Be Read",
      "dateAdded": 4,
      "order": 0,
    },
    {
      "id": "5",
      "title": "1984",
      "author": "George Orwell",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg",
      "shelf": "To Be Read",
      "dateAdded": 2,
      "order": 1,
    },
    {
      "id": "6",
      "title": "The Martian",
      "author": "Andy Weir",
      "coverUrl":
          "https://covers.openlibrary.org/b/isbn/9780553418026-L.jpg",
      "shelf": "Finished",
      "dateAdded": 1,
      "order": 0,
    },
  ];

  List<Map<String, dynamic>> get currentShelfBooks {
    final shelfBooks = books
        .where((book) => book["shelf"] == selectedShelf)
        .toList();

    if (sortBy == "Title") {
      shelfBooks.sort((firstBook, secondBook) {
        final firstTitle = firstBook["title"]
            .toString()
            .toLowerCase();

        final secondTitle = secondBook["title"]
            .toString()
            .toLowerCase();

        return firstTitle.compareTo(secondTitle);
      });
    } else if (sortBy == "Author") {
      shelfBooks.sort((firstBook, secondBook) {
        final firstAuthor = firstBook["author"]
            .toString()
            .toLowerCase();

        final secondAuthor = secondBook["author"]
            .toString()
            .toLowerCase();

        return firstAuthor.compareTo(secondAuthor);
      });
    } else if (sortBy == "Date Added") {
      shelfBooks.sort((firstBook, secondBook) {
        final firstDate = firstBook["dateAdded"] as int;
        final secondDate = secondBook["dateAdded"] as int;

        return secondDate.compareTo(firstDate);
      });
    } else {
      shelfBooks.sort((firstBook, secondBook) {
        final firstOrder = firstBook["order"] as int;
        final secondOrder = secondBook["order"] as int;

        return firstOrder.compareTo(secondOrder);
      });
    }

    return shelfBooks;
  }

  Map<String, dynamic>? findBook(String bookId) {
    for (final book in books) {
      if (book["id"] == bookId) {
        return book;
      }
    }

    return null;
  }

  void deleteBook(String bookId) {
    setState(() {
      books.removeWhere((book) => book["id"] == bookId);
      refreshShelfOrder(selectedShelf);
    });
  }

  void moveBookToShelf(String bookId, String newShelf) {
    final book = findBook(bookId);

    if (book == null) {
      return;
    }

    final oldShelf = book["shelf"].toString();

    if (oldShelf == newShelf) {
      return;
    }

    setState(() {
      book["shelf"] = newShelf;

      final newShelfBooks = books
          .where((currentBook) => currentBook["shelf"] == newShelf)
          .toList();

      book["order"] = newShelfBooks.length - 1;

      refreshShelfOrder(oldShelf);
      refreshShelfOrder(newShelf);

      selectedShelf = newShelf;
      sortBy = "Custom";
    });
  }

  void reorderBook(String draggedBookId, String targetBookId) {
    if (draggedBookId == targetBookId) {
      return;
    }

    final displayedBooks = currentShelfBooks;

    final draggedIndex = displayedBooks.indexWhere(
      (book) => book["id"] == draggedBookId,
    );

    final targetIndex = displayedBooks.indexWhere(
      (book) => book["id"] == targetBookId,
    );

    if (draggedIndex == -1 || targetIndex == -1) {
      return;
    }

    setState(() {
      final draggedBook = displayedBooks.removeAt(draggedIndex);
      displayedBooks.insert(targetIndex, draggedBook);

      for (int index = 0; index < displayedBooks.length; index++) {
        displayedBooks[index]["order"] = index;
      }

      sortBy = "Custom";
    });
  }

  void refreshShelfOrder(String shelf) {
    final shelfBooks = books
        .where((book) => book["shelf"] == shelf)
        .toList();

    shelfBooks.sort((firstBook, secondBook) {
      final firstOrder = firstBook["order"] as int;
      final secondOrder = secondBook["order"] as int;

      return firstOrder.compareTo(secondOrder);
    });

    for (int index = 0; index < shelfBooks.length; index++) {
      shelfBooks[index]["order"] = index;
    }
  }

  Widget buildShelfButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: shelves.map((shelf) {
        return DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            final draggedBook = findBook(details.data);

            if (draggedBook == null) {
              return false;
            }

            return draggedBook["shelf"] != shelf;
          },
          onAcceptWithDetails: (details) {
            moveBookToShelf(details.data, shelf);
          },
          builder: (context, candidateData, rejectedData) {
            final isSelected = shelf == selectedShelf;
            final isHovering = candidateData.isNotEmpty;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isHovering
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
              ),
              onPressed: () {
                setState(() {
                  selectedShelf = shelf;
                });
              },
              child: Text(
                isSelected ? "• $shelf" : shelf,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget buildSortDropdown() {
    return DropdownButton<String>(
      value: sortBy,
      items: const [
        DropdownMenuItem(
          value: "Custom",
          child: Text("Custom"),
        ),
        DropdownMenuItem(
          value: "Title",
          child: Text("Title"),
        ),
        DropdownMenuItem(
          value: "Author",
          child: Text("Author"),
        ),
        DropdownMenuItem(
          value: "Date Added",
          child: Text("Date Added"),
        ),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          sortBy = value;
        });
      },
    );
  }

  Widget buildDeleteArea() {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        return findBook(details.data) != null;
      },
      onAcceptWithDetails: (details) {
        deleteBook(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 70,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.red.shade300
                : Colors.red.shade100,
            border: Border.all(
              color: Colors.red.shade700,
              width: isHovering ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text(
                "Drag a book here to delete it",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBookCard(Map<String, dynamic> book) {
    final bookId = book["id"].toString();

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final draggedBook = findBook(details.data);

        if (draggedBook == null) {
          return false;
        }

        return draggedBook["shelf"] == selectedShelf &&
            details.data != bookId;
      },
      onAcceptWithDetails: (details) {
        reorderBook(details.data, bookId);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Draggable<String>(
          data: bookId,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 150,
              height: 270,
              child: buildBookVisual(
                book,
                isDragFeedback: true,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: buildBookVisual(book),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: isHovering
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: buildBookVisual(book),
          ),
        );
      },
    );
  }

  Widget buildBookVisual(
    Map<String, dynamic> book, {
    bool isDragFeedback = false,
  }) {
    return Card(
      elevation: isDragFeedback ? 10 : 2,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 150,
        height: 270,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 195,
              child: Image.network(
                book["coverUrl"].toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: Colors.black12,
                    child: Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 70,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Text(
                book["title"].toString(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: Text(
                book["author"].toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedBooks = currentShelfBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Library"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              selectedShelf,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            buildShelfButtons(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sort by: "),
                const SizedBox(width: 8),
                buildSortDropdown(),
              ],
            ),
            buildDeleteArea(),
            Expanded(
              child: displayedBooks.isEmpty
                  ? const Center(
                      child: Text("No books on this shelf yet."),
                    )
                  : GridView.builder(
                      itemCount: displayedBooks.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 190,
                        mainAxisExtent: 280,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return buildBookCard(
                          displayedBooks[index],
                        );
                      },
                    ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Return"),
            ),
          ],
        ),
      ),
    );
  }
}
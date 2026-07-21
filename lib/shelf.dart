import 'package:flutter/material.dart';

import 'book.dart';
import 'storage_service.dart';

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

  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final savedBooks = await StorageService.loadBooks();

    setState(() {
      books = savedBooks;
      isLoading = false;
    });
  }

  Future<void> saveBooks() async {
    await StorageService.saveBooks(books);
  }

  List<Book> get currentShelfBooks {
    final shelfBooks = books
        .where((book) => book.shelf == selectedShelf)
        .toList();

    if (sortBy == "Title") {
      shelfBooks.sort((a, b) {
        return a.title.toLowerCase().compareTo(
              b.title.toLowerCase(),
            );
      });
    } else if (sortBy == "Author") {
      shelfBooks.sort((a, b) {
        return a.author.toLowerCase().compareTo(
              b.author.toLowerCase(),
            );
      });
    } else if (sortBy == "Date Added") {
      shelfBooks.sort((a, b) {
        return b.dateAdded.compareTo(a.dateAdded);
      });
    }

    return shelfBooks;
  }

  Book? findBook(String id) {
    for (final book in books) {
      if (book.id == id) {
        return book;
      }
    }

    return null;
  }

  Future<void> deleteBook(String id) async {
    setState(() {
      books.removeWhere(
        (book) => book.id == id,
      );
    });

    await saveBooks();
  }

  Future<void> moveBookToShelf(
    String id,
    String newShelf,
  ) async {
    final book = findBook(id);

    if (book == null) {
      return;
    }

    setState(() {
      book.shelf = newShelf;
      selectedShelf = newShelf;
      sortBy = "Custom";
    });

    await saveBooks();
  }

  Future<void> reorderBook(
    String draggedId,
    String targetId,
  ) async {
    if (draggedId == targetId) {
      return;
    }

    final shelfBooks = currentShelfBooks;

    final draggedIndex = shelfBooks.indexWhere(
      (book) => book.id == draggedId,
    );

    final targetIndex = shelfBooks.indexWhere(
      (book) => book.id == targetId,
    );

    if (draggedIndex == -1 || targetIndex == -1) {
      return;
    }

    setState(() {
      final draggedBook = shelfBooks.removeAt(draggedIndex);

      shelfBooks.insert(
        targetIndex,
        draggedBook,
      );

      books.removeWhere(
        (book) => book.shelf == selectedShelf,
      );

      books.addAll(shelfBooks);

      sortBy = "Custom";
    });

    await saveBooks();
  }

  Widget buildShelfButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: shelves.map((shelf) {
        return DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            final book = findBook(details.data);

            if (book == null) {
              return false;
            }

            return book.shelf != shelf;
          },
          onAcceptWithDetails: (details) {
            moveBookToShelf(
              details.data,
              shelf,
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isSelected = shelf == selectedShelf;
            final isHovering = candidateData.isNotEmpty;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isHovering
                    ? Theme.of(context)
                        .colorScheme
                        .secondaryContainer
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

  Widget buildBookCard(Book book) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final draggedBook = findBook(details.data);

        if (draggedBook == null) {
          return false;
        }

        return draggedBook.shelf == selectedShelf &&
            details.data != book.id;
      },
      onAcceptWithDetails: (details) {
        reorderBook(
          details.data,
          book.id,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Draggable<String>(
          data: book.id,
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
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
    Book book, {
    bool isDragFeedback = false,
  }) {
    final coverUrl = book.coverId != null
        ? "https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg"
        : null;

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
              child: coverUrl != null
                  ? Image.network(
                      coverUrl,
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
                    )
                  : const ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 70,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Text(
                book.title,
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
                book.author,
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
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 12),

            buildShelfButtons(),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
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
                      child: Text(
                        "No books on this shelf yet.",
                      ),
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
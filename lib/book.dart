class Book {
  final String id;
  final String title;
  final String author;
  final int? coverId;
  final DateTime dateAdded;
  final String shelf;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverId,
    required this.dateAdded,
    required this.shelf,
  });

  Map<String, dynamic> toJson() {
    return {
      "id":id,
      "title":title,
      "author":author,
      "coverId":coverId,
      "dateAdded":dateAdded.toIso8601String(),
      "shelf":shelf,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json["id"],
      title: json["title"],
      author: json["author"],
      coverId: json["coverId"],
      dateAdded: DateTime.parse(json["dateAdded"]),
      shelf: json["shelf"],
    );
  }
}
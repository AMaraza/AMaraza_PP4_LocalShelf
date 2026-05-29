import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class BrowseBooksView extends StatefulWidget {
  const BrowseBooksView({super.key});

  @override
  State<BrowseBooksView> createState() => _BrowseBooksViewState();
}

Future<void> fetchData() async {

  final response = await http.get(
    Uri.parse('https://openlibrary.org/search.json?title=the+lord+of+the+rings'),
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
}

class _BrowseBooksViewState extends State<BrowseBooksView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(decoration: InputDecoration(
              labelText: "Insert Name of Book",
              hintText: "e.g. Lord of the Rings",
              border: OutlineInputBorder()
            ),),
            TextButton(onPressed: () {fetchData();}, child: Text("Search API")),
            TextButton(onPressed: () {writeTestBook();}, child: Text("Save Book")),
            TextButton(onPressed: ()=> {Navigator.pop(context)}, child: Text("Return"))
          ],
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:local_shelf/shelf.dart';
import 'package:local_shelf/browse.dart';
import 'package:local_shelf/map.dart';


void main() async {
/*WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);*/
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "LocalShelf",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShelfView(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 25),
              ),
              child: const Text("View Shelves"),
            ),

            TextButton(
              onPressed: () {                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BrowseBooksView(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 25),
              ),
              child: const Text("Search Books"),
            ),

            TextButton(
              onPressed: () {                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapView(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 25),
              ),
              child: const Text("Find Local Bookstore"),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Position? currentPosition;

  bool loading = false;

  int radius = 5000;

  List<dynamic> places = [];

  final String apiKey = "";


  Future<Position> determinePosition() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return Geolocator.getCurrentPosition();
  }


  Future<void> searchPlaces() async {
    setState(() {
      loading = true;
    });

    try {
      currentPosition = await determinePosition();

      final url = Uri.parse(
        "https://places.googleapis.com/v1/places:searchNearby",
      );


      final response = await http.post(
        url,

        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,

          // Required by the new Places API
          "X-Goog-FieldMask":
              "places.displayName,"
              "places.formattedAddress,"
              "places.location",
        },

        body: jsonEncode({
          "includedTypes": [
            "book_store",
            "library",
          ],

          "maxResultCount": 5,

          "locationRestriction": {
            "circle": {
              "center": {
                "latitude": currentPosition!.latitude,
                "longitude": currentPosition!.longitude,
              },

              "radius": radius.toDouble(),
            }
          }
        }),
      );


      print("Status Code: ${response.statusCode}");
      print(response.body);


      final data = jsonDecode(response.body);


      if (response.statusCode == 200 &&
          data["places"] != null) {

        setState(() {
          places = data["places"];
          loading = false;
        });

      } else {

        print(
          "Google Places Error: ${data["error"] ?? data}",
        );

        setState(() {
          places = [];
          loading = false;
        });
      }

    } catch (e) {

      print(e);

      setState(() {
        loading = false;
      });
    }
  }


  Future<void> openNavigation(
      double lat,
      double lng,
      ) async {

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );


    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }


  @override
  void initState() {
    super.initState();
    searchPlaces();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Bookstores"),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [

                  DropdownButton<int>(
                    value: radius,

                    items: const [

                      DropdownMenuItem(
                        value: 1000,
                        child: Text("1 km"),
                      ),

                      DropdownMenuItem(
                        value: 5000,
                        child: Text("5 km"),
                      ),

                      DropdownMenuItem(
                        value: 10000,
                        child: Text("10 km"),
                      ),

                    ],

                    onChanged: (value) {

                      setState(() {
                        radius = value!;
                      });

                      searchPlaces();
                    },
                  ),


                  const SizedBox(height: 20),


                  Expanded(
                    child: ListView.builder(

                      itemCount: places.length,

                      itemBuilder: (context, index) {

                        final place = places[index];


                        final location =
                            place["location"];


                        return Card(

                          child: ListTile(

                            title: Text(
                              place["displayName"]["text"],
                            ),


                            subtitle: Text(
                              place["formattedAddress"]
                              ??
                              "No address",
                            ),


                            trailing: ElevatedButton(

                              child: const Text(
                                "Navigate",
                              ),


                              onPressed: () {

                                openNavigation(
                                  location["latitude"],
                                  location["longitude"],
                                );

                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
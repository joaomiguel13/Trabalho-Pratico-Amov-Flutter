import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';
import 'package:locatewiki_flutter/widgets/map.dart';

class LandmarkDetailsPage extends StatelessWidget {
  const LandmarkDetailsPage(
      {super.key, required this.landmark, required this.categories});

  final Landmark landmark;
  final Set<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Landmark Details - ${landmark.title}"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title: ${landmark.title}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Other Info: ${landmark.otherInfo}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${landmark.geoPoint.latitude}, Long: ${landmark.geoPoint.longitude}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(categories
                        .firstWhere(
                            (category) => landmark.categoryId == category.id)
                        .icon
                        .icon),
                    const SizedBox(width: 8.0),
                    Text(
                      categories
                          .firstWhere(
                              (category) => landmark.categoryId == category.id)
                          .getPresentationName(),
                      style: const TextStyle(fontSize: 13.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 400.0,
              child: FutureBuilder<List<int>>(
                future: FirebaseHelper()
                    .getLandmarkImage(landmark.locationId, landmark.id)
                    .then((imageData) =>
                        imageData != null ? imageData.toList() : []),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading image');
                  } else {
                    return Image.memory(
                      Uint8List.fromList(snapshot.data!),
                      fit: BoxFit.contain,
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Map:',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 300.0,
                  width: 400.0,
                  child: Expanded(
                    child: MapWidget(
                      geoPoint: landmark.geoPoint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

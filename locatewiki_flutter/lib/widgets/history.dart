import 'dart:async';

import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';
import 'package:locatewiki_flutter/widgets/landmark_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.landmarks});

  final Set<String> landmarks;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Set<Landmark>? _landmarks;
  Set<Category>? _categories;

  late StreamSubscription _categoriesSubscription;
  late StreamSubscription _landmarksSubscription;

  List<Landmark>? getFilteredLandmarks() {
    if (_landmarks == null) {
      return null;
    }

    return _landmarks!
        .where((landmark) => widget.landmarks.contains(landmark.id))
        .toList();
  }

  @override
  void initState() {
    FirebaseHelper()
        .getCategories()
        .then((categories) => setState(() => _categories = categories));
    _categoriesSubscription = FirebaseHelper().observeCategories(
        (categories) => setState(() => _categories = categories));

    FirebaseHelper()
        .getLandmarks(null)
        .then((landmarks) => setState(() => _landmarks = landmarks));
    _landmarksSubscription = FirebaseHelper().observeLandmarks(
        null, (landmarks) => setState(() => _landmarks = landmarks));

    return super.initState();
  }

  @override
  void dispose() {
    _categoriesSubscription.cancel();
    _landmarksSubscription.cancel();

    return super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Landmark>? filteredLandmarks = getFilteredLandmarks();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("History"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            if (filteredLandmarks == null || filteredLandmarks.isEmpty)
              const Text(
                'No landmarks found',
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLandmarks.length,
                  itemBuilder: (context, index) {
                    return LandmarkCard(
                      landmark: filteredLandmarks[index],
                      categories: _categories!,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';
import 'package:locatewiki_flutter/location_helper.dart';
import 'package:locatewiki_flutter/widgets/landmark_card.dart';
import 'package:locatewiki_flutter/widgets/search_bar.dart';
import 'package:location/location.dart' as location;

class LandmarksPage extends StatefulWidget {
  const LandmarksPage({super.key, required this.location});

  final Location location;

  @override
  State<LandmarksPage> createState() => _LandmarksPageState();
}

class _LandmarksPageState extends State<LandmarksPage> {
  Set<Landmark>? _landmarks;
  Set<Category>? _categories;

  late StreamSubscription _categoriesSubscription;
  late StreamSubscription _landmarksSubscription;

  OrderBy? _orderBy;
  String? _searchText;

  location.LocationData? _currentLocation;

  List<Landmark>? getFilteredLandmarks() {
    if (_landmarks == null) {
      return null;
    }

    List<Landmark> filteredLandmarks = _landmarks!
        .where((landmark) =>
            _searchText == null ||
            _searchText!.isEmpty ||
            landmark.title.toLowerCase().contains(_searchText!.toLowerCase()))
        .toList();

    if (_orderBy != null) {
      filteredLandmarks.sort((a, b) {
        switch (_orderBy) {
          case OrderBy.name:
            return a.title.compareTo(b.title);
          case OrderBy.distance:
            if (_currentLocation == null) {
              break;
            }
            return LocationHelper()
                .calculateHaversineDistance(
                    a.geoPoint.latitude,
                    a.geoPoint.longitude,
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!)
                .compareTo(LocationHelper().calculateHaversineDistance(
                    b.geoPoint.latitude,
                    b.geoPoint.longitude,
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!));
          case OrderBy.category:
            return a.categoryId.compareTo(b.categoryId);
          default:
            break;
        }
        return a.id.compareTo(b.id);
      });
    }

    return filteredLandmarks;
  }

  @override
  void initState() {
    FirebaseHelper()
        .getCategories()
        .then((categories) => setState(() => _categories = categories));
    _categoriesSubscription = FirebaseHelper().observeCategories(
        (categories) => setState(() => _categories = categories));

    FirebaseHelper()
        .getLandmarks(widget.location.id)
        .then((landmarks) => setState(() => _landmarks = landmarks));
    _landmarksSubscription = FirebaseHelper().observeLandmarks(
        widget.location.id,
        (landmarks) => setState(() => _landmarks = landmarks));

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
        title: const Text("Landmarks"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            MySearchBar(
              orderOptions: const [
                OrderBy.name,
                OrderBy.distance,
                OrderBy.category
              ],
              onOrderSelected: (selectedOrder) {
                setState(() {
                  _orderBy = selectedOrder;
                });
              },
              onSearchTextChanged: (searchText) {
                setState(() {
                  _searchText = searchText;
                });
              },
            ),
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

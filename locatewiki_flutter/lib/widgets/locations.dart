import 'dart:async';

import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';
import 'package:locatewiki_flutter/location_helper.dart';
import 'package:locatewiki_flutter/widgets/history.dart';
import 'package:locatewiki_flutter/widgets/search_bar.dart';
import 'package:locatewiki_flutter/widgets/location_card.dart';
import 'package:location/location.dart' as location;
import 'package:shared_preferences/shared_preferences.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  Set<Location>? _locations;

  OrderBy? _orderBy;
  String? _searchText;

  location.LocationData? _currentLocation;

  List<Location>? getFilteredLocations() {
    if (_locations == null) {
      return null;
    }

    List<Location> filteredLocations = _locations!
        .where((location) =>
            _searchText == null ||
            _searchText!.isEmpty ||
            location.title.toLowerCase().contains(_searchText!.toLowerCase()))
        .toList();

    if (_orderBy != null) {
      filteredLocations.sort((a, b) {
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
          default:
            break;
        }
        return a.id.compareTo(b.id);
      });
    }

    return filteredLocations;
  }

  late StreamSubscription _locationsSubscription;

  @override
  void initState() {
    LocationHelper().getLocation((currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });

      LocationHelper().startLocationUpdates((currentLocation) {
        setState(() {
          _currentLocation = currentLocation;
        });
      });
    });

    FirebaseHelper()
        .getLocations()
        .then((locations) => setState(() => _locations = locations));
    _locationsSubscription = FirebaseHelper().observeLocations(
        (locations) => setState(() => _locations = locations));

    return super.initState();
  }

  @override
  void dispose() {
    _locationsSubscription.cancel();
    LocationHelper().stopLocationUpdates();

    return super.dispose();
  }

  void _navigateToHistoryPage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final landmarks = prefs.getStringList("history");

    final completer = Completer<void>();
    completer.future.then((_) {
      if (landmarks != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HistoryPage(landmarks: <String>{...landmarks})),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No history found'),
          ),
        );
      }
    });

    completer.complete();
  }

  @override
  Widget build(BuildContext context) {
    List<Location>? filteredLocations = getFilteredLocations();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Locations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistoryPage(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            MySearchBar(
              orderOptions: const [OrderBy.name, OrderBy.distance],
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
            if (filteredLocations == null || filteredLocations.isEmpty)
              const Text(
                'No locations found',
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    return LocationCard(location: filteredLocations[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

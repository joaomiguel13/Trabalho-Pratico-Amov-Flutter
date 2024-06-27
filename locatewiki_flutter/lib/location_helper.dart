import 'dart:async';
import 'dart:math';

import 'package:location/location.dart';

class LocationHelper {
  LocationHelper._privateConstructor();

  static final LocationHelper _instance = LocationHelper._privateConstructor();
  factory LocationHelper() => _instance;

  Location get _location => Location();

  LocationData _locationData = LocationData.fromMap({
    "latitude": 40.192639,
    "longitude": -8.411899,
  });

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Future<void> getLocation(Function(LocationData) onLocationFound) async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    onLocationFound(_locationData);
  }

  bool get isServiceEnabled => _serviceEnabled;
  PermissionStatus get permissionStatus => _permissionGranted;

  StreamSubscription<LocationData>? _locationSubscription;

  void startLocationUpdates(Function(LocationData) onLocationChanged) {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      onLocationChanged(currentLocation);
    });
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  double calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;

    double dLat = (lat2 - lat1) * (pi / 180.0);
    double dLon = (lon2 - lon1) * (pi / 180.0);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c;

    return distance;
  }
}

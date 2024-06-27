import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.geoPoint});

  final GeoPoint geoPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: MapWidget(geoPoint: geoPoint),
    );
  }
}

class MapWidget extends StatelessWidget {
  const MapWidget({super.key, required this.geoPoint});

  final GeoPoint geoPoint;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(geoPoint.latitude, geoPoint.longitude),
        initialZoom: 16.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'locatewiki_flutter',
        ),
        MarkerLayer(
          markers: [
            Marker(
              child: const Icon(Icons.location_on),
              point: LatLng(geoPoint.latitude, geoPoint.longitude),
              width: 60,
              height: 60,
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

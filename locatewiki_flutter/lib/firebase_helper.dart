import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:locatewiki_flutter/data_structs.dart';

class FirebaseHelper {
  FirebaseHelper._privateConstructor();

  static final FirebaseHelper _instance = FirebaseHelper._privateConstructor();
  factory FirebaseHelper() => _instance;

  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  Reference get _storageRef {
    return FirebaseStorage.instance.ref();
  }

  Future<Set<Location>> getLocations() async {
    var collection = await _firestore.collection("locations").get();
    var locations = <Location>{};
    for (var doc in collection.docs) {
      locations.add(Location.fromMap(doc.data()));
    }
    return locations;
  }

  Future<Set<Landmark>> getLandmarks(String? locationId) async {
    QuerySnapshot<Map<String, dynamic>> collection;

    if (locationId != null) {
      collection =
          await _firestore.collection("locations/$locationId/landmarks").get();
    } else {
      collection = await _firestore.collectionGroup("landmarks").get();
    }

    var landmarks = <Landmark>{};
    for (var doc in collection.docs) {
      landmarks.add(Landmark.fromMap(doc.data()));
    }
    return landmarks;
  }

  Future<Set<Category>> getCategories() async {
    var collection = await _firestore.collection("categories").get();
    var categories = <Category>{};
    for (var doc in collection.docs) {
      categories.add(Category.fromMap(doc.data()));
    }
    return categories;
  }

  StreamSubscription observeLocations(Function(Set<Location>) callback) {
    return _firestore.collection("locations").snapshots().listen((event) {
      var locations = <Location>{};
      for (var doc in event.docs) {
        locations.add(Location.fromMap(doc.data()));
      }
      callback(locations);
    }, cancelOnError: true);
  }

  StreamSubscription observeLandmarks(
      String? locationId, Function(Set<Landmark>) callback) {
    Query<Map<String, dynamic>> collection;

    if (locationId != null) {
      collection = _firestore.collection("locations/$locationId/landmarks");
    } else {
      collection = _firestore.collectionGroup("landmarks");
    }

    return collection.snapshots().listen((event) {
      var landmarks = <Landmark>{};
      for (var doc in event.docs) {
        landmarks.add(Landmark.fromMap(doc.data()));
      }
      callback(landmarks);
    }, cancelOnError: true);
  }

  StreamSubscription observeCategories(Function(Set<Category>) callback) {
    return _firestore.collection("categories").snapshots().listen((event) {
      var categories = <Category>{};
      for (var doc in event.docs) {
        categories.add(Category.fromMap(doc.data()));
      }
      callback(categories);
    }, cancelOnError: true);
  }

  void updateLocationLike(String id, int numLikes) async {
    await _firestore
        .collection("locations")
        .doc(id)
        .update({"numLikes": numLikes});
  }

  void updateLocationDislike(String id, int numDislikes) async {
    await _firestore
        .collection("locations")
        .doc(id)
        .update({"numDislikes": numDislikes});
  }

  void updateLandmarkLike(String locationId, String id, int numLikes) async {
    await _firestore
        .collection("locations/$locationId/landmarks")
        .doc(id)
        .update({"numLikes": numLikes});
  }

  void updateLandmarkDislike(
      String locationId, String id, int numDislikes) async {
    await _firestore
        .collection("locations/$locationId/landmarks")
        .doc(id)
        .update({"numDislikes": numDislikes});
  }

  Future<Uint8List?> getLandmarkImage(
      String locationId, String landmarkId) async {
    final ref = _storageRef.child('landmarkImages/$locationId/$landmarkId.png');
    return await ref.getData();
  }
}

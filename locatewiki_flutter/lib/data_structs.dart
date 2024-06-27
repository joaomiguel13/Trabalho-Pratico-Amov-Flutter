import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Landmark {
  String id;
  String locationId;
  String categoryId;
  String title;
  GeoPoint geoPoint;
  String otherInfo;
  List<String> usersTrust;
  Map<String, int> usersClassification;
  int numLikes;
  int numDislikes;
  String ownerId;

  Landmark({
    required this.id,
    required this.locationId,
    required this.categoryId,
    required this.title,
    required this.geoPoint,
    required this.otherInfo,
    required this.usersTrust,
    required this.usersClassification,
    required this.numLikes,
    required this.numDislikes,
    required this.ownerId,
  });

  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      id: map['id'],
      locationId: map['locationId'],
      categoryId: map['categoryId'],
      title: map['title'],
      geoPoint: map['geoPoint'],
      otherInfo: map['otherInfo'],
      usersTrust: List<String>.from(map['usersTrust']),
      usersClassification: Map<String, int>.from(map['usersClassification']),
      numLikes: map['numLikes'],
      numDislikes: map['numDislikes'],
      ownerId: map['ownerId'],
    );
  }
}

class Location {
  String id;
  String title;
  GeoPoint geoPoint;
  String otherInfo;
  List<String> usersTrust;
  int numLikes;
  int numDislikes;
  String ownerId;

  Location({
    required this.id,
    required this.title,
    required this.geoPoint,
    required this.otherInfo,
    required this.usersTrust,
    required this.numLikes,
    required this.numDislikes,
    required this.ownerId,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      title: map['title'],
      geoPoint: map['geoPoint'],
      otherInfo: map['otherInfo'],
      usersTrust: List<String>.from(map['usersTrust']),
      numLikes: map['numLikes'],
      numDislikes: map['numDislikes'],
      ownerId: map['ownerId'],
    );
  }
}

class Category {
  String id;
  String name;
  CategoryIcon icon;
  List<String> usersTrust;
  String ownerId;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.usersTrust,
    required this.ownerId,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: CategoryIcon.fromString(map['icon']),
      usersTrust: List<String>.from(map['usersTrust']),
      ownerId: map['ownerId'],
    );
  }

  String getPresentationName() {
    return icon.getPresentationName();
  }
}

enum CategoryIcon {
  museum,
  monument,
  garden,
  viewpoint,
  restaurant,
  accommodation,
  other;

  @override
  String toString() {
    switch (this) {
      case CategoryIcon.museum:
        return 'MUSEUM';
      case CategoryIcon.monument:
        return 'MONUMENT';
      case CategoryIcon.garden:
        return 'GARDEN';
      case CategoryIcon.viewpoint:
        return 'VIEWPOINT';
      case CategoryIcon.restaurant:
        return 'RESTAURANT';
      case CategoryIcon.accommodation:
        return 'ACCOMMODATION';
      case CategoryIcon.other:
        return 'OTHER';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryIcon.museum:
      case CategoryIcon.monument:
        return Icons.place;
      case CategoryIcon.garden:
        return Icons.star;
      case CategoryIcon.viewpoint:
        return Icons.account_circle;
      case CategoryIcon.restaurant:
        return Icons.shopping_cart;
      case CategoryIcon.accommodation:
        return Icons.home;
      case CategoryIcon.other:
        return Icons.place;
    }
  }

  String getPresentationName() {
    switch (this) {
      case CategoryIcon.museum:
        return 'Museum';
      case CategoryIcon.monument:
        return 'Monument';
      case CategoryIcon.garden:
        return 'Garden';
      case CategoryIcon.viewpoint:
        return 'Viewpoint';
      case CategoryIcon.restaurant:
        return 'Restaurant';
      case CategoryIcon.accommodation:
        return 'Accommodation';
      case CategoryIcon.other:
        return 'Other';
    }
  }

  static CategoryIcon fromString(String value) {
    switch (value) {
      case 'MUSEUM':
        return CategoryIcon.museum;
      case 'MONUMENT':
        return CategoryIcon.monument;
      case 'GARDEN':
        return CategoryIcon.garden;
      case 'VIEWPOINT':
        return CategoryIcon.viewpoint;
      case 'RESTAURANT':
        return CategoryIcon.restaurant;
      case 'ACCOMMODATION':
        return CategoryIcon.accommodation;
      case 'OTHER':
        return CategoryIcon.other;
      default:
        return CategoryIcon.other;
    }
  }
}

enum OrderBy { name, distance, category }

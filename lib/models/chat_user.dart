import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_locations_application/models/safe_location.dart';

class ChatUser {

  final String uid;
  final String name;
  final String phone;
  final String imageURL;
  late DateTime lastActive;
  final String safeLocation;
  final List<String> safeLocations;
  final List<String> safeLocationsLabels;

  ChatUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.imageURL,
    required this.lastActive,
    required this.safeLocation,
    required this.safeLocations,
    required this.safeLocationsLabels
  });

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    debugPrint('MayurDebugger ${_json["safe_locations"]}');
    return ChatUser(
      uid: _json["uid"],
      name: _json["name"],
      phone: _json["phone"],
      imageURL: _json["image"],
      lastActive: _json["last_active"].toDate(),
      safeLocation: _json["safe_location"],
      safeLocations: _json["safe_locations"] != null ?
      List<String>.from(_json["safe_locations"].map((location) => location.toString())) : [],
      safeLocationsLabels: _json["location_labels"] != null ?
      List<String>.from(_json["location_labels"].map((label) => label.toString())) : [],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      "phone" : phone,
      "name" : name,
      "last_active" : lastActive,
      "image" : imageURL,
      "safe_location" : safeLocation,
      "safe_locations" : safeLocations,
      "location_lables" : safeLocationsLabels,
    };
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}/";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }

  bool isAtSafeLocation() {
    //get locations list
    for (String location in safeLocations) {
      if (getDistance(location, safeLocation) < 100) {
        return true;
      }
    }
    return false;
  }

  getDistance(String safeLocation, String safeLocation2) {
    double distanceInMeters = Geolocator.distanceBetween(double.parse(safeLocation.split(',')[0]), double.parse(safeLocation.split(',')[1]), double.parse(safeLocation2.split(',')[0]), double.parse(safeLocation2.split(',')[1]));
    return distanceInMeters;
  }

}
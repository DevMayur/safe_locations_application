import 'package:safe_locations_application/models/safe_location.dart';

class ChatUser {

  final String uid;
  final String name;
  final String phone;
  final String imageURL;
  late DateTime lastActive;
  final String safeLocation;
  List<SafeLocation> safeLocations;

  ChatUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.imageURL,
    required this.lastActive,
    required this.safeLocation,
    required this.safeLocations
  });

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    return ChatUser(
        uid: _json["uid"],
        name: _json["name"],
        phone: _json["phone"],
        imageURL: _json["image"],
        lastActive: _json["last_active"].toDate(),
        safeLocation: _json["safe_location"],
        safeLocations: []);
  }

  Map<String, dynamic> toMap() {
    return {
      "phone" : phone,
      "name" : name,
      "last_active" : lastActive,
      "image" : imageURL,
      "safe_location" : safeLocation,
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
    for (SafeLocation location in safeLocations) {

    }
    return ( (safeLocation.split(",")[0]) != '0' && (safeLocation.split(",")[1]) != '0' );
  }

}
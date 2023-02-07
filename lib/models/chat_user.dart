class ChatUser {

  final String uid;
  final String name;
  final String phone;
  final String imageURL;
  late DateTime lastActive;
  final String safeLocation;

  ChatUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.imageURL,
    required this.lastActive,
    required this.safeLocation,
  });

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    return ChatUser(
        uid: _json["uid"],
        name: _json["name"],
        phone: _json["phone"],
        imageURL: _json["image"],
        lastActive: _json["last_active"].toDate(),
        safeLocation: _json["safe_location"]);
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
    return ( (safeLocation.split(",")[0]) != '0' && (safeLocation.split(",")[1]) != '0' );
  }

}
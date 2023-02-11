class SafeLocation {

  final String label;
  final String location;
  final String documentId;

  SafeLocation({
    required this.label,
    required this.location,
    required this.documentId,
  });

  factory SafeLocation.fromJSON(Map<String, dynamic> _json) {
    return SafeLocation(
      label: _json["label"],
      location: _json["location"],
      documentId: _json["documentId"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "label" : label,
      "location" : location,
      "documentId" : documentId,
    };
  }

}
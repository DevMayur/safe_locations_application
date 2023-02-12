import 'dart:async';

//packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:safe_locations_application/models/safe_location.dart';

//services
import '../models/chat_user.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//providers
import '../provider/authentication_provider.dart';


class SafeLocationProvider extends ChangeNotifier {

  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<SafeLocation> locations = [];
  late ChatUser _user;

  SafeLocationProvider(this._auth) {
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<ChatUser?> _getUser() async {
    debugPrint("Mayur getUser called");
    try {
      _database.getUser( _auth.user.uid ).then((_snapshot) {
        _user = ChatUser.fromJSON({
          "uid": _snapshot["uid"],
          "name": _snapshot["name"],
          "phone": _snapshot["phone"],
          "image": _snapshot["image"],
          "last_active": Timestamp.now(),
          "safe_location": _snapshot["safe_location"],
          "safe_locations": _snapshot["safe_locations"],
          "location_labels": _snapshot["location_labels"],
        });
        debugPrint("Mayur {update_profile_page_provider} snapshot user ${_user?.name}");
        notifyListeners();
        getSafeLocations();
        return _user;
      });
    } catch (e) {
      debugPrint("Mayur Error getting users");
      debugPrint(e.toString());
    }
  }

  void getSafeLocations() async {
    for ( int i=0; i< _user.safeLocations.length; i++ ) {
      SafeLocation location = SafeLocation(label: _user.safeLocationsLabels[i], location: _user.safeLocations[i], documentId: i);
      locations.add(location);
    }
  }

  void goBack() {
    _navigation.goBack();
  }

}
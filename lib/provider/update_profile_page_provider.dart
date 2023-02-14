import 'dart:async';

//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//providers
import '../provider/authentication_provider.dart';

//models
import '../models/chat.dart';
import '../models/chat_user.dart';

//pages
import '../pages/chat_page.dart';

class ProfilePageProvider extends ChangeNotifier {

  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  ChatUser? _user;

  ChatUser? getUser() {
    return _user != null ? _user : null;
  }

  ProfilePageProvider(this._auth) {
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
        return _user;
      });
    } catch (e) {
      debugPrint("Mayur Error getting users");
      debugPrint(e.toString());
    }
  }

  void updateSafeLocations() {
    _getUser();
  }

  Future<void> updateCurrentLocation(String safeLocation, String uid) async {
    await _database.updateSafeLocation(safeLocation, uid);
  }


}
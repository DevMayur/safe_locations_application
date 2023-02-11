import 'dart:async';

//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:safe_locations_application/models/safe_location.dart';

//services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//providers
import '../provider/authentication_provider.dart';


class SafeLocationProvider extends ChangeNotifier {

  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<SafeLocation>? locations;

  SafeLocationProvider(this._auth) {
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getSafeLocations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getSafeLocations() async {
    try {
      _database.getSafeLocations( uid: _auth.user.uid ).then((_snapshot) {
        locations = _snapshot.docs.map((_doc) {
          Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
          _data["documentId"] = _doc.id;
          return SafeLocation.fromJSON(_data);
        }).toList();
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void goBack() {
    _navigation.goBack();
  }

}
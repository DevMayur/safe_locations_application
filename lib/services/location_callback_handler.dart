import 'dart:async';
import 'package:background_locator_2/location_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'location_service_repository.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {

  static bool initializeFirebase = false;

  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    debugPrint('safe_location_mayur init ${params.toString()}');
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    debugPrint('safe_location_mayur disposed');
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    debugPrint('safe_location_mayur callback ${locationDto.toJson().toString()}');
    updateFirebaseLocation(locationDto);
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static void updateFirebaseLocation(LocationDto location) {
    // DatabaseService _dbService = GetIt.instance.get<DatabaseService>();
    // FirebaseAuth _auth = FirebaseAuth.instance;
    if ( !initializeFirebase ) {
      initializeFirebase = true;
      Firebase.initializeApp();
    }

    FirebaseFirestore _db = FirebaseFirestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;

    var latitude = location.latitude;
    var longitude = location.longitude;

    debugPrint('safe_location_mayur_123 updated ${latitude},${longitude}');

    // _dbService.updateSafeLocation('${latitude},${longitude}', _auth.currentUser!.uid);
    final reference = _db.collection('Users').doc(_auth.currentUser!.uid);
    reference.update({
      'safe_location' : '${latitude},${longitude}',
    });

  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    debugPrint('safe_location_mayur notificationCallback()');
    print('***notificationCallback');
  }
}
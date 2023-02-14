import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:safe_locations_application/provider/authentication_provider.dart';

import 'database_service.dart';
import 'file_manager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';


class LocationService {

  ReceivePort port = ReceivePort();

  String logStr = '';
  bool isRunning = false;
  late LocationDto lastLocation;
  final DatabaseService db;
  final AuthenticationProvider auth;

  LocationService(this.db, this.auth);

  Future<void> init() async {
    checkLocationPermission();
    if (IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
          (dynamic data) async {
            lastLocation = data;
        await updateUI(data);
      },
    );
    initPlatformState();
  }

  Future<void> updateUI(LocationDto data) async {

      if (data != null) {
        lastLocation = data;
        debugPrint('safe_location_mayur : ' + lastLocation.toJson().toString());
      } else {
        debugPrint('safe_location_mayur : data is null');
      }
      updateFirebaseLocation(data);

  }


  void updateFirebaseLocation(LocationDto location) {
    DatabaseService _dbService = this.db;
    AuthenticationProvider _auth = this.auth;

    var latitude = location.latitude;
    var longitude = location.longitude;

    debugPrint('safe_location_mayur ${latitude},${longitude}');

    _dbService.updateSafeLocation('${latitude},${longitude}', _auth.user.uid);
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "new location received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    var logStr = await FileManager.readLogFile();
    print('Initialization done');
    startLocator();
  }

  Future<bool> checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  Future<void> stopLocator() async{
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  Future<void> startLocator() async{
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true
        ),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 15,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)));
  }

  Future<bool> isLocationUpdateRunning() async {
    return await BackgroundLocator.isServiceRunning();
  }

  LocationDto getLastKnownLocation() {
    return lastLocation;
  }

  String getLocation() {
    return "${lastLocation.latitude},${lastLocation.longitude}";
  }

}
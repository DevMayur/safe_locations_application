//packages
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:safe_locations_application/models/chat_user.dart';
import 'package:safe_locations_application/pages/manage_safe_locations_page.dart';
import 'package:safe_locations_application/provider/update_profile_page_provider.dart';
import 'package:safe_locations_application/services/navigation_service.dart';
import 'package:safe_locations_application/widgets/custom_dialog.dart';
import 'package:safe_locations_application/widgets/rounded_image.dart';

//services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';

//widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//providers
import '../provider/authentication_provider.dart';

import 'package:safe_locations_application/user_configurations/user_colors.dart';
import 'package:geolocator/geolocator.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UpdateProfilePageState();
  }
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorageService;
  late NavigationService _navigation;
  late ProfilePageProvider _pageProvider;

  bool _isUserAtSafeLocation = false;
  bool _backgroundLocationUpdatesEnabled = false;
  bool _unsavedChanges = false;
  late UserColors _colors;

  String? _name;
  String? _safeLocation = "0,0";
  late ChatUser _user;

  PlatformFile? _profileImage;

  final _registerFormKey = GlobalKey<FormState>();
  late Position _currentPosition;
  StreamSubscription<Position>? positionStream = null;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return getUserLocation();
  }

  Future<Position> getUserLocation() async {
    late Position position;
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? retrivedPosition) {
              position = retrivedPosition!;
              debugPrint('Stream gave position : ${retrivedPosition.accuracy}');
              positionStream?.cancel();
        });

    try {
      // Set a timeout of 5 seconds for getting the current position
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).timeout(Duration(seconds: 5));
    } on TimeoutException {
      print('Timed out while getting location');
    } catch (e) {
      print('Error while getting location: $e');
    }

    return position;
  }

  _getCurrentLocation() async {
    try {
      final position = await _determinePosition().onError((error, stackTrace) {
        debugPrint('Error determining location $error');
        return Future.error(error.toString());
      });
      _currentPosition = position;
      debugPrint("location_mayur $_currentPosition");
      setState(() {

      });
    } catch (e) {
      debugPrint("location_mayur $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    _colors = GetIt.instance.get<UserColors>();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfilePageProvider>(create: (_) => ProfilePageProvider(_auth)),
        ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<ProfilePageProvider>();
      if ( _pageProvider.getUser() != null ) {
        _user = _pageProvider.getUser()!;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03,
                vertical: _deviceHeight * 0.02),
            height: _deviceHeight * 0.98,
            width: _deviceWidth * 0.97,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _deviceHeight * 0.05  ,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _profileImageField(),
                      _locationUpdatesSwitch(),
                    ],
                  ),
                  _registerForm(),

                  SizedBox(
                    height: _deviceHeight * 0.05  ,
                  ),

                  _viewOwnLocation(),
                  SizedBox(
                    height: _deviceHeight * 0.05  ,
                  ),
                  _updateProfileButton(),
                ],
              ),
            ),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
    },);

  }

  Widget _viewOwnLocation() {
    if ( _isUserAtSafeLocation ) {
      return ColoredRoundedButton(color: _colors.button_color, name: 'view my location',
          height: _deviceHeight * 0.065,
          width: _deviceWidth * 0.8,
          onPressed: () {
            launchMapUrl(_user.safeLocation);
          });
    } else {
      return Container();
    }
  }

  Future<void> launchMapUrl(String address) async {
    MapsLauncher.launchCoordinates(double.parse(address.split(',')[0]), double.parse(address.split(',')[1]));
  }

  Widget _locationUpdatesSwitch() {
    return Row(
      children: [
        Text('Enable Live Location', style: TextStyle(
          color: _colors.color_text,
        ),),
        Switch(
          value: _backgroundLocationUpdatesEnabled, onChanged: (bool value) {
          _backgroundLocationUpdatesEnabled = value;
          setState(() {});
          if ( _backgroundLocationUpdatesEnabled ) {
            _startListeningToLiveLocationUpdates();
          } else {
            _stopListeningToLiveLocationUpdates();
          }
        },
        ),
      ],
    );
  }

  void _startListeningToLiveLocationUpdates() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
          _safeLocation = (position == null ? '0,0' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        });
  }

  void _stopListeningToLiveLocationUpdates() {
    if (positionStream != null) {
      positionStream!.cancel();
    }
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then((_file) {
          setState(() {
            _profileImage = _file;
          });
        });
        _unsavedChanges = true;
      },
      child: () {
        if (_profileImage != null) {
          return RoundedImageFile(
              key: UniqueKey(),
              image: _profileImage!,
              size: _deviceHeight * 0.15);
        } else {
          return RoundedImageNetwork(
              key: UniqueKey(),
              imagePath: _user.imageURL != null
                  ? _user.imageURL
                  : "",
              size: _deviceHeight * 0.15);
        }
      }(),
    );
  }

  Widget _registerForm() {
    String a = _user.safeLocation;
    debugPrint('mayurkakade_user server $a');
    String? longitude = a.split(',')[0];
    String? lattitude = a.split(',')[1];
    if (double.parse(longitude!) != 0 && double.parse(lattitude!) != 0) {
      _isUserAtSafeLocation = true;
    } else {
      _isUserAtSafeLocation = false;
    }

    return Container(
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomUpdateTextFormField(
              text: _user.name,
                onSaved: (_value) {
                  _name = _value;
                },
                regEx: "",
                hintText: 'Name',
                obscureText: false
            ),

            SizedBox(
              height: _deviceHeight * 0.05  ,
            ),

            _safeLocations(),

            //  Button to manage safe locations
            SizedBox(
              height: _deviceHeight * 0.05  ,
            ),

            _manageLocations(),

            SizedBox(
              height: _deviceHeight * 0.05  ,
            ),

            ColoredRoundedButton(
                color: _isUserAtSafeLocation ? _colors.button_safe : _colors.button_unsafe,
                name: _isUserAtSafeLocation ? 'Set Myself unsafe' : 'Add Safe Location',
                height: _deviceHeight * 0.065,
                width: _deviceWidth * 0.8,
                onPressed: () async {
                  _unsavedChanges = true;
                  if ( !_isUserAtSafeLocation ) {
                    debugPrint('locations 1 : ${_safeLocation}');
                    await _getCurrentLocation();
                    if (_currentPosition != null ) {
                      _safeLocation = "${_currentPosition.latitude},${_currentPosition.longitude}";
                    } else {
                      _safeLocation = "0,0";
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(location: _safeLocation!, safeLocations: _user.safeLocations, locationLabels: _user.safeLocationsLabels, profilePageProvider: _pageProvider,);
                      },
                    );
                  } else {
                    _safeLocation = "0,0";
                  }
                  print('after set location $_safeLocation');
                  setState(() {});
                }),
          ],
        ),
      ),
    );
  }

  Widget _safeLocations() {
    return Container(
      child:
        Text(
          _isUserAtSafeLocation ? 'User is at safe location' : 'User is not at safe location',
          style: TextStyle(
            color: _colors.color_text,
            fontSize: 24,
          ),
        ),
    );
  }

  Widget _manageLocations() {
    return ColoredRoundedButton(
        color: _colors.message_background,
        name: 'Manage Safe Locations',
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.65,
        onPressed: () {
          _navigation.navigateToPage(ManageSafeLocationsPage(
              isUserAtSafeLocation: _isUserAtSafeLocation,
              safeLocation: _safeLocation!
          )
          );
          setState(() {});
        });
  }


  Widget _updateProfileButton() {
    return RoundedButton(name: 'Update Profile ${_unsavedChanges ? '(unsaved)' : ''}',
        height: _deviceHeight * 0.065,
        width: _deviceWidth * 0.8,
        onPressed: () async {
          _registerFormKey.currentState?.save();
          String? _uid = _auth.user.uid;
          String? _imageURL;
          if (_profileImage != null)
          {
            _imageURL = await _cloudStorageService.saveUserImageToStorage(_uid, _profileImage!);
          }
          else
          {
            _imageURL = _user.imageURL;
          }
          _navigation.removeAndNavigateToRoute('/home');
          if (!_unsavedChanges) {
            _safeLocation = _user.safeLocation;
          }
      print('mayurkakade final location $_safeLocation');
          await _db.updateUser(
              _uid,
              _name!,
              _imageURL!,
              _safeLocation!
          );
        });
  }
}

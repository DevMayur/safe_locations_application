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
import 'package:safe_locations_application/services/location_service.dart';
import 'package:safe_locations_application/services/navigation_service.dart';
import 'package:safe_locations_application/widgets/custom_dialog.dart';
import 'package:safe_locations_application/widgets/rounded_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // late Position _currentPosition;
  // StreamSubscription<Position>? positionStream = null;
  late LocationService _locationService;

  @override
  void initState() {
    super.initState();
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
    _locationService = LocationService(_db, _auth);
    _locationService.init().then((_) {
      _locationService.isLocationUpdateRunning().then((value) => () {
        getPreviousValueOfLocationUpdates();
      });
    });

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
                      // _locationUpdatesSwitch(),
                    ],
                  ),
                  SizedBox(
                    height: _deviceHeight * 0.05  ,
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
          value: _backgroundLocationUpdatesEnabled, onChanged: (bool value) async {
          _backgroundLocationUpdatesEnabled = value;
          await setBackgroundUpdates(value);
          if ( _backgroundLocationUpdatesEnabled ) {
            _startListeningToLiveLocationUpdates();
          } else {
            _stopListeningToLiveLocationUpdates();
          }
          setState(() {});
        },
        ),
      ],
    );
  }

  void _startListeningToLiveLocationUpdates() async {
    _locationService.startLocator();
  }

  Future<void> _stopListeningToLiveLocationUpdates() async {
    // if (positionStream != null) {
    //   positionStream!.cancel();
    // }
    await _locationService.stopLocator();
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
    if (_user.isAtSafeLocation()) {
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
        onPressed: () async {
          debugPrint('safe_location_mayurkakade_ last loc : ');
          // await _pageProvider.updateCurrentLocation( _locationService.getLocation() , _auth.user.uid );
          debugPrint('safe_location_mayurkakade_ last loc : ${_user.safeLocation}');
          _navigation.navigateToPage(ManageSafeLocationsPage(
              isUserAtSafeLocation: _isUserAtSafeLocation,
              safeLocation: _user.safeLocation!
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

  Future<bool> getPreviousValueOfLocationUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isLocationEnabled = false;
    isLocationEnabled = prefs.getBool("UpdatesEnabled");
    _backgroundLocationUpdatesEnabled = isLocationEnabled!;
    return _backgroundLocationUpdatesEnabled;
  }

  Future<void> setBackgroundUpdates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("UpdatesEnabled", value);
  }
}

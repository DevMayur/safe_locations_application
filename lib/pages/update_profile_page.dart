//packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:safe_locations_application/models/chat_user.dart';
import 'package:safe_locations_application/provider/update_profile_page_provider.dart';
import 'package:safe_locations_application/services/navigation_service.dart';
import 'package:safe_locations_application/widgets/rounded_image.dart';
import 'package:geolocator/geolocator.dart';

//services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';

//widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//providers
import '../provider/authentication_provider.dart';

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


  String? _name;
  String? _safeLocation = "[0,0]";
  late ChatUser _user;

  PlatformFile? _profileImage;

  final _registerFormKey = GlobalKey<FormState>();
  late Position _currentPosition;

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
      debugPrint('location_mayur Location services are disabled.');
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
        debugPrint('location_mayur Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      debugPrint('location_mayur Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    debugPrint('location_mayur calling await Geolocator.getCurrentPosition()');
    return await Geolocator.getCurrentPosition();
  }

  _getCurrentLocation() async {
    try {
      final position = await _determinePosition();
      _currentPosition = position;
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profileImageField(),
                _registerForm(),
                _updateProfileButton(),
              ],
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

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then((_file) {
          setState(() {
            _profileImage = _file;
          });
        });
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
    return Container(
      height: _deviceHeight * 0.35,
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

            ColoredRoundedButton(
                color: Colors.green,
                name: 'Set Myself at safe location',
                height: _deviceHeight * 0.065,
                width: _deviceWidth * 0.8,
                onPressed: () async {
                  await _getCurrentLocation();
                  _safeLocation = _currentPosition != null
                      ? "${_currentPosition.latitude},${_currentPosition.longitude}"
                      : "-1,-1";
                }),
          ],
        ),
      ),
    );
  }

  Widget _safeLocations() {
    return Container();
  }

  Widget _updateProfileButton() {
    return RoundedButton(name: 'Update Profile',
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
          await _db.updateUser(
              _uid,
              _name!,
              _imageURL!,
              _safeLocation!
          );
        });
  }
}

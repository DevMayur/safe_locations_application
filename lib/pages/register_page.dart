//packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
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

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorageService;

  String? _name;

  PlatformFile? _profileImage;

  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
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
              imagePath: "https://i.pravatar.cc/1000?img=65",
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

            CustomTextFormField(
                onSaved: (_value) {
                  _name = _value;
                },
                regEx: "",
                hintText: 'Name',
                obscureText: false),

            SizedBox(
              height: _deviceHeight * 0.05  ,
            ),

            _safeLocations(),

            RoundedButton(name: 'Add Safe Location',
                height: _deviceHeight * 0.065,
                width: _deviceWidth * 0.65,
                onPressed: () {

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
        width: _deviceWidth * 0.65,
        onPressed: () async {
          _registerFormKey.currentState?.save();
          String? _uid = _auth.user.uid;
          String? _imageURL = await _cloudStorageService.saveUserImageToStorage(_uid!, _profileImage!);
          await _db.createUser(_uid, _name!, _imageURL!, _auth.user.phone);
          setState(() {});
        });
  }
}

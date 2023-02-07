import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:safe_locations_application/services/database_service.dart';

//widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../provider/authentication_provider.dart';

//services
import '../services/navigation_service.dart';
import '../services/database_service.dart';
import 'package:country_picker/country_picker.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late DatabaseService _db;

  String? _phone;
  String? _otp;
  String? _countryCode;

  bool otpVisibility = false;
  String _verificationID = "";
  int? _resendToken;

  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
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
            _pageTitle(),
            //_selectCountry(),
            _loginForm(),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
            _loginButton(),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
            //_registerAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: const Text(
        'Safe Location',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: _deviceHeight * 0.18,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (_value) {
                _phone = _value;
              },
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: 'Enter Phone Number to Login',
              obscureText: false,
            ),
            Visibility(
              visible: otpVisibility,
              child: CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _otp = _value;
                  });
                },
                regEx: "",
                hintText: 'Enter Otp',
                obscureText: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    if ( _countryCode == null ) {
      return RoundedButton(name: 'Select Country', height: _deviceHeight * 0.065,
          width: _deviceWidth * 0.65, onPressed: () {
            _selectCountry();
          });
    }
    else {
      return RoundedButton(
          name: !otpVisibility ? "Send Otp" : "Submit",
          height: _deviceHeight * 0.065,
          width: _deviceWidth * 0.65,
          onPressed: () {
            if (_loginFormKey.currentState!.validate()) {
              _loginFormKey.currentState!.save();
              setState(() {
                if (!otpVisibility) {
                  debugPrint('${_countryCode}${_phone!}');
                  _auth.loginUsingPhoneNumber('${_countryCode}${_phone!}',
                      onCodeSent: (String verificationId, int? resendToken) {
                        _verificationID = verificationId;
                        _resendToken = resendToken;
                      });
                  otpVisibility ? {otpVisibility = false} : {
                    otpVisibility = true
                  };
                } else {
                  _auth.verifyOtp(_verificationID, _resendToken, _otp!,
                      onLoginCompleted: (bool success) {
                        if (success) {
                          debugPrint('mlogin login successful');
                          _navigation.removeAndNavigateToRoute('/home');
                        } else {
                          if (_auth.user != null) {
                            _navigation.removeAndNavigateToRoute('/register');
                            debugPrint("mlogin user registration");
                          } else {
                            debugPrint('mlogin Login Failed');
                          }
                        }
                      });
                }
              });
            }
          });
    }
  }

  Widget _registerAccountLink() {
    return GestureDetector(
      onTap: () {},
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: const Text(
          "Don't have an account ?",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
    );
  }

  _selectCountry() {
    showCountryPicker(
      showPhoneCode: true,
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: 500, // Optional. Country list modal height
        //Optional. Sets the border radius for the bottomsheet.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _countryCode = '+${country.phoneCode}';
        });
      },
    );
  }
}

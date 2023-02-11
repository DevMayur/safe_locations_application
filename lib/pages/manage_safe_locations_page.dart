import 'package:flutter/material.dart';

import '../provider/authentication_provider.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class ManageSafeLocationsPage extends StatefulWidget{
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
  @override
  State<StatefulWidget> createState() {
    return ManageSafeLocationPageState();
  }
}

class ManageSafeLocationPageState extends State<ManageSafeLocationsPage> {
  @override
  Widget build(BuildContext context) {
    return _buildUI(context);
  }

  Widget _buildUI(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(

        ),
      ),
    );
  }
}


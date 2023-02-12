import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//providers
import '../provider/authentication_provider.dart';
import '../provider/update_profile_page_provider.dart';

//services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class CustomDialog extends StatefulWidget {
  final String location;
  final List<String> safeLocations;
  final List<String> locationLabels;
  final ProfilePageProvider profilePageProvider;

  CustomDialog({required this.location, required this.safeLocations, required this.locationLabels, required this.profilePageProvider});

  @override
  _CustomDialogState createState() => _CustomDialogState(
      location: location,
      safeLocations: safeLocations,
      locationLabels: locationLabels,
      profilePageProvider: profilePageProvider,
  );
}

class _CustomDialogState extends State<CustomDialog> {
  final _textController = TextEditingController();
  final String location;
  final List<String> safeLocations;
  final List<String> locationLabels;
  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late DatabaseService _database;
  final ProfilePageProvider profilePageProvider;


  _CustomDialogState({required this.location, required this.safeLocations, required this.locationLabels, required this.profilePageProvider});

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _database = GetIt.instance.get<DatabaseService>();
    return AlertDialog(
      title: Text('Add your current location in your safe locations list.'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: 'Enter label here'),
      ),
      actions: <Widget>[
        OutlinedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        OutlinedButton(
          child: Text('Submit'),
          onPressed: () async {
            await _storeSafeLocation( _textController.text );
            profilePageProvider.updateSafeLocations();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Future<void> _storeSafeLocation( String label ) async {
    await _database.addIntoSafeLocations( _auth.user.uid, label, location, safeLocations, locationLabels );
  }
}
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//providers
import '../provider/authentication_provider.dart';

//services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class CustomDialog extends StatefulWidget {
  final String location;

  CustomDialog({required this.location});

  @override
  _CustomDialogState createState() => _CustomDialogState(
      location: location
  );
}

class _CustomDialogState extends State<CustomDialog> {
  final _textController = TextEditingController();
  final String location;
  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late DatabaseService _database;

  _CustomDialogState({required this.location});

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
            _storeSafeLocation( _textController.text );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _storeSafeLocation( String label ) async {
    _database.addIntoSafeLocations( _auth.user.uid, label, location );
  }
}
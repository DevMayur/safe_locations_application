import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:safe_locations_application/models/safe_location.dart';
import 'package:safe_locations_application/provider/safe_location_provider.dart';

import '../provider/authentication_provider.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../user_configurations/user_colors.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/top_bar.dart';

class ManageSafeLocationsPage extends StatefulWidget{
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late DatabaseService _db;

  bool otpVisibility = false;

  final bool isUserAtSafeLocation;
  final String safeLocation;

  ManageSafeLocationsPage({required this.isUserAtSafeLocation, required this.safeLocation});

  @override
  State<StatefulWidget> createState() {
    return ManageSafeLocationPageState(
        isUserAtSafeLocation: this.isUserAtSafeLocation,
        safeLocation: this.safeLocation
    );
  }
}

class ManageSafeLocationPageState extends State<ManageSafeLocationsPage> {
  final bool isUserAtSafeLocation;
  final String safeLocation;

  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late SafeLocationProvider _pageProvider;

  late ScrollController _messagesListViewController;
  late UserColors _colors;

  ManageSafeLocationPageState({required this.isUserAtSafeLocation, required this.safeLocation});

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    _deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _colors = GetIt.instance.get<UserColors>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SafeLocationProvider>(
            create: (_) => SafeLocationProvider(_auth)
        ),
      ],
      child: _buildUI(context),
    );
  }

  Widget _buildUI(_context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                location: safeLocation,
                safeLocations: _pageProvider.locations.map((loc) => loc.location).toList(),
                locationLabels: _pageProvider.locations.map((loc) => loc.label).toList(),
                profilePageProvider: _pageProvider,
              );
            },
          );
        },
        child: Icon(
          Icons.add
        ),
      ),
      body: Builder(builder: (BuildContext _context) {
        _pageProvider = _context.watch<SafeLocationProvider>();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                "Safe Locations",
                onTap: () {},
              ),
              _usersList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _usersList() {
    List<SafeLocation>? _safeLocations = _pageProvider.locations;
    return Expanded(
      child: () {
        if (_safeLocations != null) {
          if (_safeLocations.isNotEmpty) {
            return ListView.builder(
                itemCount: _safeLocations.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return CustomListViewTileWithSafetyStatus(
                      height: _deviceHeight * 0.10,
                      title: _safeLocations[_index].label,
                      subtitle: getDistanceString(safeLocation, _safeLocations[_index] ),
                      imagePath: 'https://img.icons8.com/nolan/96/user-location.png',
                      isActive: getDistance(safeLocation, _safeLocations[_index]) > 100 ? false : true,
                      isActivity: false,
                      onTap: () {
                        // if (_safeLocations[_index].isAtSafeLocation()) {
                        //   _viewOwnLocation(_users[_index]);
                        // }
                      });
                });
          } else {
            return const Center(
              child: Text(
                "No Users found",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      }(),
    );
  }

  getDistanceString(String safeLocation, SafeLocation safeLocation2) {
    double distanceInMeters = calculateDistance(double.parse(safeLocation.split(',')[0]), double.parse(safeLocation.split(',')[1]), double.parse(safeLocation2.location.split(',')[0]), double.parse(safeLocation2.location.split(',')[1]));
    debugPrint('safeLocation : ${safeLocation}');
    debugPrint('safeLocation2 : ${safeLocation2.location}');
    debugPrint('safeLocation2 : ${safeLocation2.label}');
    return '${(distanceInMeters).toInt()} m away';
  }

  getDistance(String safeLocation, SafeLocation safeLocation2) {
    double distanceInMeters = calculateDistance(double.parse(safeLocation.split(',')[0]), double.parse(safeLocation.split(',')[1]), double.parse(safeLocation2.location.split(',')[0]), double.parse(safeLocation2.location.split(',')[1]));
    return distanceInMeters;
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}


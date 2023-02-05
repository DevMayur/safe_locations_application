import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safe_locations_application/user_configurations/user_colors.dart';

//pages
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';

import 'package:get_it/get_it.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    required Key key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3)).then((_) => {
          _setup().then(
            (_) => widget.onInitializationComplete(),
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeLocation',
      theme: ThemeData(
        backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
        scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            height: 96,
            width: 96,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/safe_location.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _registerServices();
  }

  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(
      NavigationService(),
    );

    GetIt.instance.registerSingleton<MediaService>(
      MediaService(),
    );

    GetIt.instance.registerSingleton<CloudStorageService>(
      CloudStorageService(),
    );

    GetIt.instance.registerSingleton<DatabaseService>(
      DatabaseService(),
    );

    UserColors userColors = UserColors(
        background_color: Color.fromRGBO(218, 218, 218, 1.0),
        color_primary: Color.fromRGBO(92, 140, 217, 1.0),
        color_text: Colors.black,
        color_input: Colors.white,
        button_color: Color.fromRGBO(0, 82, 218, 1.0),
        button_safe: Colors.green,
        button_unsafe: Colors.red,
        message_background:Colors.lightGreen ,
      navigation_bar_icons:Color.fromRGBO(0, 82, 218, 1.0),
      navigation_bar_background:Color.fromRGBO(161, 161, 161, 1.0),
    );

    GetIt.instance.registerSingleton<UserColors>(
        userColors
    );
  }
}

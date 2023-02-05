import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Pages
import './pages/splash_page.dart';
import './pages/home_page.dart';
import './pages/register_page.dart';

//services
import './services/navigation_service.dart';
import './pages/login_page.dart';

//providers
import './provider/authentication_provider.dart';

import 'package:safe_locations_application/user_configurations/user_colors.dart';
import 'package:get_it/get_it.dart';

void main() {
  runApp(SplashPage(
    key: UniqueKey(),
    onInitializationComplete: () {
      runApp(MainApp());
    },
  ));
}

class MainApp extends StatelessWidget {
  late UserColors _colors;
  @override
  Widget build(BuildContext context) {
    _colors = GetIt.instance.get<UserColors>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider();
          },),
      ],
      child: MaterialApp(
        title: 'Safe Location',
        theme: ThemeData(
          backgroundColor: _colors.background_color,
          scaffoldBackgroundColor: _colors.background_color,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: _colors.navigation_bar_background,
          ),
        ),
        home: const Scaffold(

        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
          '/register': (BuildContext _context) => RegisterPage(),
          '/home': (BuildContext _context) => HomePage(),
        },
      ),
    );
  }
}

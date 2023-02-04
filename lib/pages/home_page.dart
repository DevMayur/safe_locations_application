import 'package:flutter/material.dart';
import 'package:safe_locations_application/pages/register_page.dart';
import 'package:safe_locations_application/pages/update_profile_page.dart';
import 'package:safe_locations_application/pages/users_page.dart';
import 'chats_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }

}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final List<Widget> _pages = [
    ChatsPage(),
    UsersPage(),
    UpdateProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (_index) {
          setState(() {
            _currentPage = _index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Chats',
            icon: Icon(Icons.chat_bubble_sharp),
          ),
          BottomNavigationBarItem(
            label: 'Users',
            icon: Icon(Icons.supervised_user_circle_sharp),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_2),
          ),
        ],
      ),
    );
  }
}
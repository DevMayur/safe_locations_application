//packages
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//providers
import 'package:provider/provider.dart';
import 'package:safe_locations_application/provider/users_page_provider.dart';
import 'package:url_launcher/url_launcher.dart';

//widgets
import '../models/chat_user.dart';
import '../provider/authentication_provider.dart';
import '../widgets/rounded_button.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';

//models
import '../models/chat.dart';
import '../models/chat_message.dart';

//providers
import '../provider/chats_page_provider.dart';
import '../provider/chat_page_provider.dart';

import '../user_configurations/user_colors.dart';

class GroupUsersPage extends StatefulWidget {

  final Chat chat;

  GroupUsersPage({required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _GroupUsersPageState();
  }
}

class _GroupUsersPageState extends State<GroupUsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late UsersPageProvider _pageProvider;

  late ScrollController _messagesListViewController;
  late UserColors _colors;

  @override
  void initState() {
    _messagesListViewController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _colors = GetIt.instance.get<UserColors>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(create: (_) => UsersPageProvider(_auth)),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<UsersPageProvider>();
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.02,
            ),
            height: _deviceHeight,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(
                  widget.chat.title(),
                  fontSize: 12,
                  secondaryAction: IconButton(
                    icon: Icon(Icons.arrow_back, color: _colors.button_color,),
                    onPressed: () {

                    },
                  ),
                  onTap: () {},
                ),
                _usersList(),
                // _sendMessageForm(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _usersList() {
    List<ChatUser>? _users = widget.chat.members;
    return Expanded(
      child: () {
        if(_users != null) {
          if (_users.isNotEmpty ) {
            return ListView.builder(
                itemCount: _users.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return CustomListViewTileWithSafetyStatus(
                      height: _deviceHeight * 0.10,
                      title: _users[_index].name,
                      subtitle: "Last Active: ${_users[_index].lastDayActive()}",
                      imagePath: _users[_index].imageURL,
                      isActive: _users[_index].isAtSafeLocation(),
                      isActivity: false,
                      onTap: () {
                        if ( _users[_index].isAtSafeLocation() ) {
                          _viewOwnLocation(_users[_index]);
                        }
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


  void _viewOwnLocation(ChatUser _user) {
    launchMapUrl(_user.safeLocation);
  }

  Future<void> launchMapUrl(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
    String appleMapUrl = "http://maps.apple.com/?q=$encodedAddress";
    if (Platform.isAndroid) {
      try {
        if (await canLaunch(googleMapUrl)) {
          await launch(googleMapUrl);
        } else {
          throw 'Could not launch $googleMapUrl';
        }
      } catch (error) {
        throw("Cannot launch Google map");
      }
    }
    if (Platform.isIOS) {
      try {
        if (await canLaunch(appleMapUrl)) {
          await launch(appleMapUrl);
        } else {
          throw 'Could not launch $appleMapUrl';
        }
      } catch (error) {
        throw("Cannot launch Apple map");
      }
    }
  }


}
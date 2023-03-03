//packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:safe_locations_application/models/chat_message.dart';
import 'package:safe_locations_application/models/chat_user.dart';
import 'package:safe_locations_application/widgets/custom_list_view_tiles.dart';

//providers
import '../provider/authentication_provider.dart';
import '../provider/chats_page_provider.dart';

//Widgets
import '../widgets/top_bar.dart';

//models
import '../models/chat.dart';

//services
import '../services/navigation_service.dart';

//pages
import '../pages/chat_page.dart';

import 'package:safe_locations_application/user_configurations/user_colors.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatsPageProvider _pageProvider;
  late NavigationService _navigation;
  late UserColors _colors;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _colors = GetIt.instance.get<UserColors>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _pageProvider = _context.watch<ChatsPageProvider>();
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: _colors.heading_color,
                  ),
                  onPressed: () {
                    _auth.logOut();
                  },
                ),
                onTap: () {},
              ),
              _chatsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? _chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if(_chats != null) {
          if(_chats.length != 0)
          {
            return ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return _chatTile(_chats[_index]);
                }
            );
          }
          else
          {
            return Center(
              child: Text(
                "No Chats Found",
                style: TextStyle(
                  color: _colors.color_text,
                ),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: _colors.color_input,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recepients =_chat.recepients();
    bool _isActive = _recepients.any((_d) {
      return false;
    });
    String _subtitleText = "";
    if (_chat.messages.isNotEmpty) {
      _subtitleText = _chat.messages.first.type != MessageType.TEXT ? "Media Attachment" : _chat.messages.first.content;
    }
    return CustomListViewTileWithActivity(
        height: _deviceHeight * 0.10,
        title: _chat.title(),
        subtitle: _subtitleText,
        imagePath: _chat.imageURL(),
        isActive: _isActive,
        isActivity: _chat.activity,
        onTap: () {
          _navigation.navigateToPage(
              ChatPage(chat: _chat),
          );
        });
  }
}

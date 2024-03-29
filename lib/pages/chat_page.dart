//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//providers
import 'package:provider/provider.dart';
import 'package:safe_locations_application/pages/group_users_page.dart';
import 'package:safe_locations_application/services/navigation_service.dart';

//widgets
import '../provider/authentication_provider.dart';
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

class ChatPage extends StatefulWidget {

  final Chat chat;

  ChatPage({required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  late UserColors _colors;

  @override
  void initState() {
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _colors = GetIt.instance.get<UserColors>();
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
        providers: [
      ChangeNotifierProvider<ChatPageProvider>(
        create: (_) => ChatPageProvider(
            widget.chat.uid,
            _auth,
            _messagesListViewController,
        ),
      )
    ],
    child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<ChatPageProvider>();
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
                  primaryAction: IconButton(
                    icon: Icon(Icons.delete,
                      color: _colors.heading_color,
                    ),
                    onPressed: () {
                      _pageProvider.deleteChat();
                    },
                  ),
                  secondaryAction: IconButton(
                    icon: Icon(Icons.arrow_back, color: _colors.heading_color,),
                    onPressed: () {
                      _pageProvider.goBack();
                    },
                  ),
                  onTap: () {
                    _navigation.navigateToPage(GroupUsersPage(chat: widget.chat));
                  },
                ),
                _messagesListView(),
                _sendMessageForm(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return Container(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: _messagesListViewController,
              itemCount: _pageProvider.messages!.length,
              itemBuilder: (BuildContext _context, int _index) {
                ChatMessage _message = _pageProvider.messages![_index];
                bool _isOwnMessage = _message.senderID == _auth.user.uid;
                return Container(
                  child: CustomChatListViewTile(
                    deviceHeight: _deviceHeight,
                    width: _deviceHeight * 0.80,
                    message: _message,
                    isOwnMessage: _isOwnMessage,
                    sender: widget.chat.members
                        .where((_m) => _m.uid == _message.senderID)
                        .first,
                  ),
                );
              }),
        );
      } else {
        return Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first one to say hello!",
            style: TextStyle(color: _colors.color_text),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: _colors.color_text,
        ),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: _colors.color_input,
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sendMessageButton(),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
          onSaved: (_value) {
            _pageProvider.message = _value;
          },
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obscureText: false),
    );
  }

  Widget _sendMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _pageProvider.sendTextMessage();
            _messageFormState.currentState!.reset();
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _imageMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}
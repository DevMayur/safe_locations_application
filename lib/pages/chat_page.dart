//packages
import 'package:flutter/material.dart';

//providers
import 'package:provider/provider.dart';

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

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;

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
                    icon: const Icon(Icons.delete, color: Color.fromRGBO(0, 82, 218, 1.0),),
                    onPressed: () {},
                  ),
                  secondaryAction: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(0, 82, 218, 1.0),),
                    onPressed: () {},
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    });
  }

}
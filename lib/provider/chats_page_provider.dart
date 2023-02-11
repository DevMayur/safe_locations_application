import 'dart:async';

//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//services
import '../services/database_service.dart';

//providers
import '../provider/authentication_provider.dart';

//models
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;

  late StreamSubscription _chatStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _chatStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      _chatStream =
          _db.getChatsForUser(_auth.user.uid).listen((_snapshot) async {
        chats = await Future.wait(_snapshot.docs.map((_d) async {
          Map<String, dynamic> _chatData = _d.data() as Map<String, dynamic>;

          //Get users in chat
          List<ChatUser> _members = [];
          for (var _uid in _chatData["members"]) {
            DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
            if (_userSnapshot != null && _userSnapshot.data() != null) {
              Map<String, dynamic> _userData =
              _userSnapshot.data() as Map<String, dynamic>;
              _userData["uid"] = _userSnapshot.id;
              _userData["safe_locations"] = _db.getLocations(_userSnapshot.id);
              _members.add(ChatUser.fromJSON(_userData));
            }
          }

          //Get last message For chat
          List<ChatMessage> _messages = [];
          QuerySnapshot _chatMessage = await _db.getLastMessageForChat(_d.id);
          if (_chatMessage.docs.isNotEmpty) {
            Map<String, dynamic> _messageData =
                _chatMessage.docs.first.data()! as Map<String, dynamic>;
            ChatMessage _message = ChatMessage.fromJSON(_messageData);
            _messages.add(_message);
          }
          //Return chat instance
          return Chat(
              uid: _d.id,
              currentUserUid: _auth.user.uid,
              messages: _messages,
              members: _members,
              activity: _chatData["is_activity"],
              group: _chatData["is_group"]);
        }).toList());
        notifyListeners();
      });
    } catch (e) {
      print("Error getting chats");
      print(e);
    }
  }
}
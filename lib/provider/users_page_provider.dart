import 'dart:async';

//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//providers
import '../provider/authentication_provider.dart';

//models
import '../models/chat.dart';
import '../models/chat_user.dart';

//pages
import '../pages/chat_page.dart';
import 'package:fast_contacts/fast_contacts.dart';

class UsersPageProvider extends ChangeNotifier {

  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? users;
  List<ChatUser>? registeredUsers;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUsers();
    getRegisteredContacts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getRegisteredContacts({String? name}) async {
    final List<Contact> _contacts = await FastContacts.allContacts;
    // debugPrint("Mayur $name");
    _selectedUsers = [];
    try {
      _database.getUsers( name: name ).then((_snapshot) {
        registeredUsers = _snapshot.docs.map((_doc) {
          Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
          _data["uid"] = _doc.id;
          return ChatUser.fromJSON(_data);
        }).toList();

        List<String> numbersList = [];
        for ( Contact contact in _contacts ) {
          for (String number in contact.phones) {
            numbersList.add(number);
          }
        }

        List<ChatUser>? tempUsers = List.from(registeredUsers!);

        String ownNumber = _auth.user.phone;

        for (ChatUser user in tempUsers) {
          if (user.phone == ownNumber) {
            registeredUsers?.remove(user);
          }
          if (!checkNumber(user,numbersList)) {
            registeredUsers?.remove(user);
            debugPrint('removed_____ ${user.phone}');
          } else {
            debugPrint('not removed_____ ${user.phone}');
          }
        }

        notifyListeners();
      });
    } catch (e) {
      debugPrint("Mayur Error getting users");
      debugPrint(e.toString());
    }
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      _database.getUsers( name: name ).then((_snapshot) {
        users = _snapshot.docs.map((_doc) {
          Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
          _data["uid"] = _doc.id;
          return ChatUser.fromJSON(_data);
        }).toList();
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Mayur Error getting users");
      debugPrint(e.toString());
    }
  }

  updateSelectedUsers(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      List<String> _membersIds = _selectedUsers.map((_user) => _user.uid).toList();
      _membersIds.add(_auth.user.uid);
      bool _isGroup = _selectedUsers.length > 1;
      DocumentReference? _doc = await _database.createChat({
        "is_group": _isGroup,
        "is_activity": false,
        "members": _membersIds,
      });
      //navigate to chat page
      List<ChatUser> _members = [];
      for (var _uid in _membersIds) {
        DocumentSnapshot _userSnapshot = await _database.getUser(_uid);
        Map<String,dynamic> _userData = _userSnapshot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapshot.id;
        _members.add(ChatUser.fromJSON(_userData,),);
      }
      ChatPage _chatPage = ChatPage(chat:
      Chat(uid: _doc!.id,
          currentUserUid: _auth.user.uid,
          messages: [],
          members: _members,
          activity: false,
          group: _isGroup)
      );
      _selectedUsers = [];
      notifyListeners();
      _navigation.navigateToPage(_chatPage);
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  bool checkNumber(ChatUser user, List<String> numbersList) {
    return contactContains(numbersList, user.phone);
  }

  bool contactContains( List<String> numberList, String number ) {
    for (String num in numberList) {
      if( newString(number
          .replaceAll(' ', '')
          .replaceAll('+', ' ')
          .replaceAll('-', '')
          .replaceAll('(', '')
          .replaceAll(')', ''), 10)
       ==
          ( newString(num
              .replaceAll('+', '')
              .replaceAll(' ', '')
              .replaceAll('-', '')
              .replaceAll('(', '')
              .replaceAll(')', ''), 10) ) )
      {
        return true;
      }
    }
    return false;
  }

  String newString(String oldString, int n) {
    if (oldString.length >= n) {
      return oldString.substring(oldString.length - n);
    } else {
      return oldString;
    }
  }

}
import 'dart:async';

//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

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

class GroupUsersPageProvider extends ChangeNotifier {

  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? members;

  Chat chat;
  String groupName;

  List<ChatUser> getMembers() {
    return members!;
  }

  GroupUsersPageProvider(this._auth, this.members, this.groupName, this.chat) {
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    listenToUserChanges();
  }

  void goBack() {
    _navigation.goBack();
  }

  void listenToUserChanges() async {
    //navigate to chat page
    List<ChatUser> _members = [];
    FirebaseFirestore _db = FirebaseFirestore.instance;
    for (var _member in members!) {
      _db.collection(USER_COLLECTION)
          .doc(_member.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          ChatUser member = ChatUser.fromJSON(snapshot.data()!);
          debugPrint('member123 : ${member.toMap().toString()}');
          int index = _members.indexWhere((element) => element.uid == member.uid);
          if (index >= 0) {
            _members[index] = member;
          } else {
            _members.add(member);
          }
          members = _members;
          notifyListeners();
        } else {
          debugPrint('member123 snapshot does not exist');
        }
      });
    }
  }

  void updateChatName() {
    _database.updateGroupName(chat.uid, groupName);
  }

  void setGroupName({required String name}) {
    groupName = name;
  }

}
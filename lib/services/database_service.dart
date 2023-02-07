import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:safe_locations_application/models/chat_message.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGES_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<DocumentSnapshot> getUser( String _uid )
  {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Future<QuerySnapshot> getUsers( {String? name} )
  {
    debugPrint("Mayur Getting Users from $USER_COLLECTION");
    Query _query = _db.collection( USER_COLLECTION );
    if ( name != null )
    {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }
    debugPrint("Mayur Returned QuerySnapshot");
    return _query.get();
  }

  // Future<QuerySnapshot> getGroupUsers( {required String chatId} ) {
  //   debugPrint("Mayur Getting Users from $USER_COLLECTION");
  //
  //   // Query _query = _db.collection( CHAT_COLLECTION ).doc(chatId).
  //
  //
  //   Query _query = _db.collection( USER_COLLECTION );
  //   if ( name != null )
  //   {
  //     _query = _query
  //         .where("name", isGreaterThanOrEqualTo: name)
  //         .where("name", isLessThanOrEqualTo: name + "z");
  //   }
  //   debugPrint("Mayur Returned QuerySnapshot");
  //   return _query.get();
  // }

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db.collection(CHAT_COLLECTION).where('members', arrayContains: _uid).snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatId) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatId)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addMessageToChat(String _chatID, ChatMessage _message) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatID)
          .collection(MESSAGES_COLLECTION)
          .add(
            _message.toJson()
          );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateChatData(String _chatID, Map<String, dynamic> _data) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).update(_data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime( String _uid ) async
  {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).update({
        "last_active": DateTime.now().toUtc(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkIfUserExist( String _uid ) async
  {
    print("userId $_uid" );
    try {
      CollectionReference usersCollection = _db.collection(USER_COLLECTION);
      var doc = await usersCollection.doc(_uid).get();
      return doc.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> deleteChat(String _chatID) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat = await _db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch(e) {
        debugPrint("create chat failed");
    }
  }


  Future<void> createUser(String _uid, String _name, String _imageURL, String _phone) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set({
        "uid": _uid,
        "name": _name,
        "phone": _phone,
        "image": _imageURL,
        "last_active": DateTime.now().toUtc(),
        "safe_location": -2,
      });
    } catch(e) {
      print(e);
    }
  }

  Future<void> updateUser(String _uid, String _name, String _imageURL, String _safeLocation) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).update({
        "uid": _uid,
        "name": _name,
        "image": _imageURL,
        "last_active": DateTime.now().toUtc(),
        "safe_location": _safeLocation,
      });
    } catch(e) {
      print(e);
    }
  }

}

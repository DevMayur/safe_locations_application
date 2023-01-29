import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

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

}

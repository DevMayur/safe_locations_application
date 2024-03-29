import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//models
import '../models/chat_user.dart';

//services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;
  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        debugPrint('mayurkakade__ $_user');
        user = ChatUser.fromJSON({
          "uid": _auth.currentUser?.uid,
          "name": "--",
          "phone": _auth.currentUser?.phoneNumber,
          "image": "dafault",
          "last_active": Timestamp.now(),
          "safe_location": "0,0",
          "safe_locations": [],
          "location_labels": [],
        });
        _databaseService.updateUserLastSeenTime(_user.uid);
        debugPrint('mayurkakade__ ${_user.phoneNumber}');
        _databaseService.getUser(_user.uid).then(
          (_snapshot) {
            _databaseService
                .checkIfUserExist(_auth.currentUser!.uid)
                .then((userExist) {
              if (!userExist) {
                print('user not exist');
                _navigationService.removeAndNavigateToRoute('/register');
              } else {
                print('user exist');
                _navigationService.removeAndNavigateToRoute('/home');
              }
            });
          },
        );
      } else {
        print('not logged in');
        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  Future<void> loginUsingPhoneNumber(String _phone,
      {required Function onCodeSent}) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) {
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseException {
      print('Firebase Exception logging in');
    } catch (e) {
      print(e);
    }
  }

  void verifyOtp(String verificationId, int? resendToken, String otp,
      {required Function onLoginCompleted}) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    await _auth.signInWithCredential(phoneAuthCredential).then((value) {
      if (_auth.currentUser != null) {
        _databaseService.getUser(_auth.currentUser!.uid).then((_snapshot) {
          if (_snapshot != null && _snapshot.exists) {
            onLoginCompleted(true);
          }
          else
          {
            onLoginCompleted(false);
          }
        });
      } else {
        onLoginCompleted(false);
      }
    });
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}

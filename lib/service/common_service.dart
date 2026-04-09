// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class CommonService {
  CommonService._();

  static final CommonService _instance = CommonService._();

  factory CommonService() => _instance;

  // Future<void> configureFirebase() async {
  //   debugPrint('config');
  //   await Firebase.initializeApp();
  //   FirebaseAuth.instance.createUserWithEmailAndPassword(
  //     email: "test@example.com",
  //     password: "password123",
  //   );
  //
  // }
}
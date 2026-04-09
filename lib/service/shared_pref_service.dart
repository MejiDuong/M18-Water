import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  SharedPrefService._internal();

  static final SharedPrefService instance = SharedPrefService._internal();

  factory SharedPrefService() {
    return instance;
  }

  static Future<bool> checkFirstLaunch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(
        "IS FIRST LAUNCH: ${(prefs.getBool('first_run') ?? true).toString()}");
    if (prefs.getBool('first_run') ?? true) {
      prefs.setBool('first_run', false);
      // await Get.find<SecureStorageService>().deleteAllData();
      return true;
    } else {
      return false;
    }
  }
}
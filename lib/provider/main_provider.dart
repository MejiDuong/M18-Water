import 'package:untitled/base/base_view.dart';

class MainProvider extends ViewCommonService {
  static MainProvider? _instance;

  String _accessToken = "";
  String _typeUser = "";
  String _userName = "Hoang Anh";

  String get accessToken => _accessToken;

  String get typeUser => _typeUser;
  String get userName => _userName;
}
import 'package:get/get.dart';
import 'package:untitled/provider/main_provider.dart';

class ProfileController {
  MainProvider mainProvider = MainProvider();
  var email = 'hoanganh@gmail.com';
  RxBool isConfirmEmail = false.obs;
  RxString eventLabel = '6.6'.obs;
}
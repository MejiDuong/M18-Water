import 'package:get/get.dart';
import 'package:untitled/provider/main_provider.dart';

class BaseController extends GetxController {
  // final MainProvider mainProvider = Get.find<MainProvider>();

  void hideKeyboard() {
    Get.focusScope?.unfocus();
  }
}
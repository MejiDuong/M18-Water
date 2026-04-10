import 'package:get/get.dart';

class MainController extends GetxController {
  // Biến .obs để theo dõi người dùng đang ở tab nào (0: Today, 1: History, 2: Insights)
  var currentTab = 0.obs;

  void changeTab(int index) {
    currentTab.value = index;
  }
}
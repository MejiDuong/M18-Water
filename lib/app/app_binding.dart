import 'package:get/get.dart';
import '../modules/mainScene/water_controller.dart';
import '../modules/mainScene/main_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(WaterController(), permanent: true);
    // Get.lazyPut(() => MainController());
  }
}

import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Auth & Sync state
  var isLoggedIn = true.obs;
  var isSyncing = false.obs;
  var userName = "Albert Flores".obs;
  var email = "alma.lawson@gmail.com".obs;
  var lastSyncTime = "09:51 AM".obs;

  // Statistics
  var totalDrinking = 8.36.obs;
  var totalAchievedDays = 11.obs;
  void toggleSync() async {
    if (isSyncing.value) return;
    isSyncing.value = true;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Update last sync time
    lastSyncTime.value = "10:51 AM";
    isSyncing.value = false;
    
    Get.snackbar(
      "Success", 
      "Data synchronized successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    isLoggedIn.value = false;
  }
  
  void login() {
    isLoggedIn.value = true;
  }
}
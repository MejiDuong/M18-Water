import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../service/notification_service.dart';
import 'package:intl/intl.dart';

class DrinkLog {
  final double amount;
  final DateTime time;

  DrinkLog({required this.amount, required this.time});
}

class WaterController extends GetxController {
  final _storage = GetStorage();
  final _notificationService = NotificationService();

  var totalWater = 0.0.obs;
  var goalWater = 2000.0.obs;
  var dailyLogs = <DrinkLog>[].obs;
  
  var selectedLogIndex = (-1).obs;
  
  // Logic Reminder
  var isReminderOn = true.obs;
  var reminderTime = const TimeOfDay(hour: 11, minute: 0).obs;
  var notificationPermissionGranted = true.obs;
  var timeLeftString = "".obs;
  var nextReminderDay = "".obs;
  Timer? _timer;

  final ScrollController scrollController = ScrollController();

  double get percentage => (totalWater.value / goalWater.value);

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    checkNotificationPermission();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      updateTimeLeft();
    });
    updateTimeLeft();
  }

  void updateTimeLeft() {
    if (!isReminderOn.value) {
      timeLeftString.value = "";
      nextReminderDay.value = "";
      return;
    }

    final now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, reminderTime.value.hour, reminderTime.value.minute);
    
    // Nếu đã qua giờ hoặc đã đạt mục tiêu -> Tính cho ngày mai
    if (scheduled.isBefore(now) || percentage >= 1.0) {
      if (percentage >= 1.0 && scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      } else if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      nextReminderDay.value = DateFormat('EEEE').format(scheduled);
    } else {
      nextReminderDay.value = "";
    }

    final difference = scheduled.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    // Định dạng: (4h 32min left)
    timeLeftString.value = "(${hours}h ${minutes}min left)";
  }

  Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    notificationPermissionGranted.value = status.isGranted;
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    notificationPermissionGranted.value = status.isGranted;
    if (status.isGranted && isReminderOn.value) _updateNotification();
  }

  void _loadSettings() {
    isReminderOn.value = _storage.read('isReminderOn') ?? true;
    int? hour = _storage.read('reminderHour');
    int? minute = _storage.read('reminderMinute');
    if (hour != null && minute != null) {
      reminderTime.value = TimeOfDay(hour: hour, minute: minute);
    }
    if (isReminderOn.value) _updateNotification();
  }

  void updateReminderTime(TimeOfDay newTime) {
    reminderTime.value = newTime;
    _storage.write('reminderHour', newTime.hour);
    _storage.write('reminderMinute', newTime.minute);
    isReminderOn.value = true;
    _storage.write('isReminderOn', true);
    _updateNotification();
    updateTimeLeft();
  }

  void _updateNotification() {
    _notificationService.scheduleDailyNotification(
      reminderTime.value.hour,
      reminderTime.value.minute,
    );
  }

  void addWater(double amount) {
    totalWater.value += amount;
    dailyLogs.add(DrinkLog(amount: amount, time: DateTime.now()));
    updateTimeLeft();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void removeLog(int index) {
    if (index >= 0 && index < dailyLogs.length) {
      totalWater.value -= dailyLogs[index].amount;
      dailyLogs.removeAt(index);
      selectedLogIndex.value = -1;
      updateTimeLeft();
    }
  }
  
  void selectLog(int index, double screenWidth) {
    if (selectedLogIndex.value == index) {
      selectedLogIndex.value = -1;
    } else {
      selectedLogIndex.value = index;
      const double itemWidth = 96.0; 
      final double targetOffset = index * itemWidth;

      if (scrollController.hasClients) {
        scrollController.animateTo(
          targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}

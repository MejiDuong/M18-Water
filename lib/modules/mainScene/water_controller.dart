import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DrinkLog {
  final double amount;
  final DateTime time;
  DrinkLog({required this.amount, required this.time});

  Map<String, dynamic> toJson() => {'amount': amount, 'time': time.toIso8601String()};
  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(amount: json['amount'], time: DateTime.parse(json['time']));
}

class WaterController extends GetxController {
  final box = GetStorage();

  var totalWater = 0.0.obs;
  var goalWater = 2000.0.obs;

  // Kho 1: Chỉ chứa nước hôm nay (Reset mỗi ngày)
  var dailyLogs = <DrinkLog>[].obs;

  // Kho 2: Chứa nước từ cổ chí kim (Không bao giờ reset)
  var historyLogs = <DrinkLog>[].obs;

  var selectedLogIndex = (-1).obs;
  var currentTab = 0.obs;

  final ScrollController scrollController = ScrollController();

  double get percentage => (totalWater.value / goalWater.value);

  List<double> get dayChartData {
    List<double> hourlyIntake = List.filled(25, 0.0);
    for (var log in dailyLogs) {
      if (log.time.day == DateTime.now().day) {
        hourlyIntake[log.time.hour] += log.amount;
      }
    }
    List<double> cumulative = List.filled(25, 0.0);
    double sum = 0;
    for (int i = 0; i < 25; i++) {
      sum += hourlyIntake[i];
      cumulative[i] = sum;
    }
    return cumulative;
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ==========================================
  // LOGIC LƯU TRỮ VÀ LOAD DỮ LIỆU ĐÃ FIX LỖI
  // ==========================================
  void _loadData() {
    String todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    String? lastSavedDate = box.read('lastDate');

    // 1. Luôn luôn load lịch sử vĩnh cửu (History) trước
    List? storedHistory = box.read('historyLogs');
    if (storedHistory != null) {
      historyLogs.value = storedHistory.map((e) => DrinkLog.fromJson(e)).toList();
    }

    // 2. Kiểm tra ngày mới
    if (lastSavedDate != todayStr) {
      // Ngày mới -> Reset kho Hôm Nay, NHƯNG giữ nguyên kho History
      totalWater.value = 0.0;
      dailyLogs.clear();
      box.write('lastDate', todayStr);
      _saveToDisk();
    } else {
      // Vẫn là hôm nay -> Load lại kho Hôm Nay
      totalWater.value = box.read('totalWater') ?? 0.0;
      List? storedLogs = box.read('dailyLogs');
      if (storedLogs != null) {
        dailyLogs.value = storedLogs.map((e) => DrinkLog.fromJson(e)).toList();
      }
    }
  }

  void _saveToDisk() {
    box.write('totalWater', totalWater.value);
    box.write('dailyLogs', dailyLogs.map((e) => e.toJson()).toList());
    box.write('historyLogs', historyLogs.map((e) => e.toJson()).toList()); // Lưu thêm history
  }

  void addWater(double amount) {
    totalWater.value += amount;
    var newLog = DrinkLog(amount: amount, time: DateTime.now());

    // Thêm vào cả 2 kho
    dailyLogs.add(newLog);
    historyLogs.add(newLog);

    _saveToDisk();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void removeLog(int index) {
    if (index >= 0 && index < dailyLogs.length) {
      var logToRemove = dailyLogs[index];
      totalWater.value -= logToRemove.amount;

      // Xóa khỏi kho Hôm nay
      dailyLogs.removeAt(index);

      // Đồng bộ xóa luôn ở kho History (dựa vào thời gian uống)
      historyLogs.removeWhere((element) => element.time == logToRemove.time);

      selectedLogIndex.value = -1;
      _saveToDisk();
    }
  }

  void selectLog(int index, double screenWidth) {
    if (selectedLogIndex.value == index) {
      selectedLogIndex.value = -1;
    } else {
      selectedLogIndex.value = index;
      const double totalItemWidth = 102.0;
      final double targetOffset = index * totalItemWidth;
      if (scrollController.hasClients) {
        scrollController.animateTo(targetOffset.clamp(0.0, scrollController.position.maxScrollExtent), duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
      }
    }
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}
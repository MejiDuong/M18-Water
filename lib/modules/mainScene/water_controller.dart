import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DrinkLog {
  final double amount;
  final DateTime time;
  DrinkLog({required this.amount, required this.time});

  // Biến data thành chuỗi để lưu vào ổ cứng
  Map<String, dynamic> toJson() => {'amount': amount, 'time': time.toIso8601String()};
  // Dịch chuỗi từ ổ cứng ra lại data
  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(amount: json['amount'], time: DateTime.parse(json['time']));
}

class WaterController extends GetxController {
  final box = GetStorage(); // Hộp lưu trữ

  var totalWater = 0.0.obs;
  var goalWater = 2000.0.obs;
  var dailyLogs = <DrinkLog>[].obs;

  var selectedLogIndex = (-1).obs;
  var currentTab = 0.obs;

  final ScrollController scrollController = ScrollController();

  double get percentage => (totalWater.value / goalWater.value);

  // ... (Giữ nguyên hàm dayChartData) ...
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
    _loadData(); // Tự động load dữ liệu khi mở app
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ==========================================
  // LOGIC LƯU TRỮ VÀ LOAD DỮ LIỆU
  // ==========================================
  void _loadData() {
    String todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    String? lastSavedDate = box.read('lastDate');

    // Nếu sang ngày mới -> Reset sạch sẽ
    if (lastSavedDate != todayStr) {
      totalWater.value = 0.0;
      dailyLogs.clear();
      box.write('lastDate', todayStr);
      _saveToDisk();
    } else {
      // Nếu vẫn là hôm nay -> Load lại dữ liệu cũ
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
  }

  // ==========================================
  // CÁC HÀM XỬ LÝ (Có gọi thêm hàm lưu)
  // ==========================================
  void addWater(double amount) {
    totalWater.value += amount;
    dailyLogs.add(DrinkLog(amount: amount, time: DateTime.now()));
    _saveToDisk(); // LƯU SAU KHI UỐNG

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void removeLog(int index) {
    if (index >= 0 && index < dailyLogs.length) {
      totalWater.value -= dailyLogs[index].amount;
      dailyLogs.removeAt(index);
      selectedLogIndex.value = -1;
      _saveToDisk(); // LƯU SAU KHI XÓA
    }
  }

  // ... (Giữ nguyên các hàm selectLog, changeTab) ...
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
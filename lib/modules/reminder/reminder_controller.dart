import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../service/notification_service.dart';
import '../mainScene/water_controller.dart';

// CÁC CLASS DỮ LIỆU ĐƯỢC NÂNG CẤP ĐỂ LƯU TRỮ
class StandardReminder {
  final String name;
  final RxString time;
  final RxBool isEnabled;

  StandardReminder({required this.name, required String time, bool isEnabled = true})
      : time = time.obs,
        isEnabled = isEnabled.obs;

  Map<String, dynamic> toJson() => {'name': name, 'time': time.value, 'isEnabled': isEnabled.value};
  factory StandardReminder.fromJson(Map<String, dynamic> json) => StandardReminder(name: json['name'], time: json['time'], isEnabled: json['isEnabled']);
}

class CustomTime {
  final RxString time;
  final RxBool isEnabled;

  CustomTime({required String time, bool isEnabled = true})
      : time = time.obs,
        isEnabled = isEnabled.obs;

  Map<String, dynamic> toJson() => {'time': time.value, 'isEnabled': isEnabled.value};
  factory CustomTime.fromJson(Map<String, dynamic> json) => CustomTime(time: json['time'], isEnabled: json['isEnabled']);
}

class ReminderController extends GetxController {
  final box = GetStorage();

  // 1. Công tắc tổng & Chế độ
  var isMasterOn = true.obs;
  var currentMode = 0.obs;
  var tempSelectedMode = 0.obs;

  // BIẾN HIỂN THỊ ĐẾM NGƯỢC LÊN MÀN HÌNH
  var nextReminderTime = "00:00 AM".obs;
  var timeLeft = "".obs;
  Timer? _timer;

  // DANH SÁCH GIỜ CỦA CÁC CHẾ ĐỘ
  final standardReminders = <StandardReminder>[].obs;
  final weekendStandardReminders = <StandardReminder>[].obs;

  var intervalDuration = "1 hour 30 min".obs;
  var bedtimeStart = "11:00 PM".obs;
  var bedtimeEnd = "08:00 AM".obs;

  var weekendIntervalDuration = "2 hours".obs;
  var weekendBedtimeStart = "11:00 PM".obs;
  var weekendBedtimeEnd = "08:00 AM".obs;

  var customTimes = <CustomTime>[].obs;

  // ==========================================
  // CÀI ĐẶT CHUNG (Footer)
  // ==========================================
  var isWeekendModeOn = false.obs;
  var stopWhenGoalAchieved = true.obs;
  var isSmartSkipOn = true.obs;
  var smartSkipDuration = "1 hour".obs;

  //  KIỂM TRA ĐÃ ĐẠT MỤC TIÊU NƯỚC CHƯA
  bool get _isGoalMet {
    try {
      final waterCtrl = Get.find<WaterController>();
      return waterCtrl.totalWater.value >= waterCtrl.goalWater.value;
    } catch (e) {
      return false; // Nếu chưa load được WaterController thì coi như chưa đạt
    }
  }

  // LOGIC XỬ LÝ BẬT/TẮT CÔNG TẮC TỔNG
  Future<void> toggleMasterSwitch(bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.status;

      if (status.isPermanentlyDenied) {
        isMasterOn.value = false;
        await openAppSettings();
        return;
      }

      if (!status.isGranted) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        isMasterOn.value = true;
      } else {
        isMasterOn.value = false;
      }
    } else {
      isMasterOn.value = false;
    }

    _saveToDisk();
    calculateNextReminder();
    _updateScheduledNotifications();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _setupAutoSave();

    calculateNextReminder();
    _updateScheduledNotifications();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) => calculateNextReminder());

    // [MỚI] LẮNG NGHE LƯỢNG NƯỚC UỐNG ĐỂ CẬP NHẬT LẠI BÁO THỨC NGAY LẬP TỨC
    try {
      final waterCtrl = Get.find<WaterController>();
      ever(waterCtrl.totalWater, (_) {
        calculateNextReminder();
        _updateScheduledNotifications();
      });
    } catch (e) {
      debugPrint("Chưa tìm thấy WaterController");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // LẤY DANH SÁCH GIỜ ĐANG BẬT
  List<DateTime> _getActiveTimes() {
    DateTime now = DateTime.now();
    List<DateTime> allActiveTimes = [];
    bool isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (currentMode.value == 0) {
      var activeList = (isWeekend && isWeekendModeOn.value) ? weekendStandardReminders : standardReminders;
      for (var item in activeList) {
        if (item.isEnabled.value) allActiveTimes.add(_parseTime(item.time.value));
      }
    }
    else if (currentMode.value == 1) {
      String dur = (isWeekend && isWeekendModeOn.value) ? weekendIntervalDuration.value : intervalDuration.value;
      String bStart = (isWeekend && isWeekendModeOn.value) ? weekendBedtimeStart.value : bedtimeStart.value;
      String bEnd = (isWeekend && isWeekendModeOn.value) ? weekendBedtimeEnd.value : bedtimeEnd.value;

      DateTime start = _parseTime(bEnd);
      DateTime end = _parseTime(bStart);
      if (end.isBefore(start)) end = end.add(const Duration(days: 1));

      Duration step = _parseDurationStr(dur);
      if (step.inMinutes > 0) {
        DateTime current = start;
        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          allActiveTimes.add(current);
          current = current.add(step);
        }
      }
    }
    else if (currentMode.value == 2) {
      for (var item in customTimes) {
        if (item.isEnabled.value) allActiveTimes.add(_parseTime(item.time.value));
      }
    }

    return allActiveTimes.toSet().toList();
  }

  // NẠP BÁO THỨC VÀO HỆ ĐIỀU HÀNH (ĐÃ THÊM LOGIC SKIP GOAL)
  Future<void> _updateScheduledNotifications() async {
    await NotificationService().cancelAll();

    if (!isMasterOn.value) return;

    List<DateTime> activeTimes = _getActiveTimes();
    DateTime now = DateTime.now();

    // NẾU BẬT CÔNG TẮC & ĐÃ UỐNG ĐỦ -> CỜ "BỎ QUA HÔM NAY" = TRUE
    bool skipToday = stopWhenGoalAchieved.value && _isGoalMet;
    int idCounter = 0;

    for (var time in activeTimes) {
      DateTime scheduleTime = time;

      // Nếu giờ đã qua, tự đẩy sang ngày mai
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      // ĐẨY TIẾP SANG NGÀY MAI NẾU ĐÃ ĐẠT MỤC TIÊU HÔM NAY
      if (skipToday && scheduleTime.day == now.day) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      await NotificationService().scheduleDailyNotification(
        idCounter,
        scheduleTime, // Bắt buộc NotificationService phải được sửa để nhận biến DateTime
      );
      idCounter++;
    }
    debugPrint("===> ĐÃ LÊN LỊCH ${activeTimes.length} BÁO THỨC <===");
  }

  // TỰ ĐỘNG TẠO CHUỖI GIỜ INTERVAL HIỂN THỊ UI
  String getWeekdayIntervalText() {
    return _generateIntervalText(intervalDuration.value, bedtimeEnd.value, bedtimeStart.value);
  }

  String getWeekendIntervalText() {
    return _generateIntervalText(weekendIntervalDuration.value, weekendBedtimeEnd.value, weekendBedtimeStart.value);
  }

  String _generateIntervalText(String durationStr, String startStr, String endStr) {
    DateTime start = _parseTime(startStr);
    DateTime end = _parseTime(endStr);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));

    Duration step = _parseDurationStr(durationStr);
    List<String> times = [];

    if (step.inMinutes > 0) {
      DateTime current = start;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        times.add(DateFormat("hh:mm a").format(current));
        current = current.add(step);
      }
    }
    return times.join(", ");
  }

  // THUẬT TOÁN TÍNH GIỜ TIẾP THEO HIỂN THỊ LÊN UI (ĐÃ THÊM LOGIC SKIP GOAL)
  void calculateNextReminder() {
    if (!isMasterOn.value) {
      nextReminderTime.value = "Off";
      timeLeft.value = "";
      return;
    }

    List<DateTime> allActiveTimes = _getActiveTimes();

    if (allActiveTimes.isEmpty) {
      nextReminderTime.value = "No Alarms";
      timeLeft.value = "";
      return;
    }

    DateTime now = DateTime.now();
    bool skipToday = stopWhenGoalAchieved.value && _isGoalMet;

    List<DateTime> validTimes = [];
    for (var t in allActiveTimes) {
      DateTime scheduleTime = t;
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      if (skipToday && scheduleTime.day == now.day) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      validTimes.add(scheduleTime);
    }

    validTimes.sort();
    DateTime nextTime = validTimes.first;

    // HIỂN THỊ THÔNG BÁO NẾU ĐÃ ĐẠT GOAL
    if (skipToday) {
      nextReminderTime.value = "Goal Met! Next: ${DateFormat("hh:mm a").format(nextTime)}";
    } else {
      nextReminderTime.value = DateFormat("hh:mm a").format(nextTime);
    }

    Duration diff = nextTime.difference(now);
    int hours = diff.inHours;
    int minutes = diff.inMinutes % 60;
    timeLeft.value = "(${hours > 0 ? '${hours}h ' : ''}${minutes.toString().padLeft(2, '0')} min left)";
  }

  // --- Parser ---
  DateTime _parseTime(String timeStr) {
    try {
      final time = DateFormat("hh:mm a").parse(timeStr);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  Duration _parseDurationStr(String durStr) {
    int hours = 0;
    int mins = 0;
    String lower = durStr.toLowerCase();

    if (lower.contains("hour")) {
      var parts = lower.split("hour");
      hours = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    if (lower.contains("min")) {
      var parts = lower.split("min");
      String minStr = parts[0];
      if (lower.contains("hour")) {
        minStr = lower.split("hour").last;
      }
      mins = int.tryParse(minStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return Duration(hours: hours, minutes: mins);
  }

  // LƯU TRỮ VÀ TẢI DỮ LIỆU
  void _loadData() {
    isMasterOn.value = box.read('isMasterOn') ?? true;
    currentMode.value = box.read('currentMode') ?? 0;

    intervalDuration.value = box.read('intervalDuration') ?? "1 hour 30 min";
    bedtimeStart.value = box.read('bedtimeStart') ?? "11:00 PM";
    bedtimeEnd.value = box.read('bedtimeEnd') ?? "08:00 AM";

    weekendIntervalDuration.value = box.read('weekendIntervalDuration') ?? "2 hours";
    weekendBedtimeStart.value = box.read('weekendBedtimeStart') ?? "11:00 PM";
    weekendBedtimeEnd.value = box.read('weekendBedtimeEnd') ?? "08:00 AM";

    isWeekendModeOn.value = box.read('isWeekendModeOn') ?? false;
    stopWhenGoalAchieved.value = box.read('stopWhenGoalAchieved') ?? true;
    isSmartSkipOn.value = box.read('isSmartSkipOn') ?? true;
    smartSkipDuration.value = box.read('smartSkipDuration') ?? "1 hour";

    List? storedStandard = box.read('standardReminders');
    if (storedStandard != null) {
      standardReminders.value = storedStandard.map((e) => StandardReminder.fromJson(e)).toList();
    } else {
      standardReminders.addAll([
        StandardReminder(name: 'After Wake-up', time: '07:00 AM'),
        StandardReminder(name: 'Before Breakfast', time: '08:20 AM'),
        StandardReminder(name: 'After Breakfast', time: '09:30 AM'),
        StandardReminder(name: 'Before Lunch', time: '11:00 AM'),
        StandardReminder(name: 'After Lunch', time: '01:00 PM'),
        StandardReminder(name: 'Before Dinner', time: '06:00 PM'),
        StandardReminder(name: 'After Dinner', time: '08:00 PM'),
        StandardReminder(name: 'Before Sleep', time: '10:00 PM'),
      ]);
    }

    List? storedWeekend = box.read('weekendStandardReminders');
    if (storedWeekend != null) {
      weekendStandardReminders.value = storedWeekend.map((e) => StandardReminder.fromJson(e)).toList();
    } else {
      weekendStandardReminders.addAll([
        StandardReminder(name: 'After Wake-up', time: '08:00 AM'),
        StandardReminder(name: 'Before Breakfast', time: '09:00 AM'),
        StandardReminder(name: 'After Breakfast', time: '10:00 AM'),
        StandardReminder(name: 'Before Lunch', time: '12:00 PM'),
        StandardReminder(name: 'After Lunch', time: '01:30 PM'),
        StandardReminder(name: 'Before Dinner', time: '06:30 PM'),
        StandardReminder(name: 'After Dinner', time: '08:00 PM'),
        StandardReminder(name: 'Before Sleep', time: '11:00 PM'),
      ]);
    }

    List? storedCustom = box.read('customTimes');
    if (storedCustom != null) {
      customTimes.value = storedCustom.map((e) => CustomTime.fromJson(e)).toList();
    } else {
      customTimes.addAll([
        CustomTime(time: '06:30 AM', isEnabled: false),
        CustomTime(time: '08:00 AM', isEnabled: true),
        CustomTime(time: '09:30 AM', isEnabled: true),
        CustomTime(time: '11:00 AM', isEnabled: true),
        CustomTime(time: '12:30 PM', isEnabled: true),
        CustomTime(time: '02:00 PM', isEnabled: true),
        CustomTime(time: '03:30 PM', isEnabled: true),
        CustomTime(time: '05:00 PM', isEnabled: true),
        CustomTime(time: '06:30 PM', isEnabled: true),
        CustomTime(time: '08:00 PM', isEnabled: true),
        CustomTime(time: '09:30 PM', isEnabled: true),
        CustomTime(time: '11:00 PM', isEnabled: false),
      ]);
    }
  }

  void _setupAutoSave() {
    everAll([
      isMasterOn, currentMode, intervalDuration, bedtimeStart, bedtimeEnd,
      weekendIntervalDuration, weekendBedtimeStart, weekendBedtimeEnd,
      isWeekendModeOn, stopWhenGoalAchieved, isSmartSkipOn, smartSkipDuration
    ], (_) {
      _saveToDisk();
      calculateNextReminder();
      _updateScheduledNotifications();
    });

    for (var item in standardReminders) { ever(item.isEnabled, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); ever(item.time, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); }
    for (var item in weekendStandardReminders) { ever(item.isEnabled, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); ever(item.time, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); }
    for (var item in customTimes) { ever(item.isEnabled, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); ever(item.time, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications(); }); }
  }

  void _saveToDisk() {
    box.write('isMasterOn', isMasterOn.value);
    box.write('currentMode', currentMode.value);
    box.write('intervalDuration', intervalDuration.value);
    box.write('bedtimeStart', bedtimeStart.value);
    box.write('bedtimeEnd', bedtimeEnd.value);
    box.write('weekendIntervalDuration', weekendIntervalDuration.value);
    box.write('weekendBedtimeStart', weekendBedtimeStart.value);
    box.write('weekendBedtimeEnd', weekendBedtimeEnd.value);
    box.write('isWeekendModeOn', isWeekendModeOn.value);
    box.write('stopWhenGoalAchieved', stopWhenGoalAchieved.value);
    box.write('isSmartSkipOn', isSmartSkipOn.value);
    box.write('smartSkipDuration', smartSkipDuration.value);

    box.write('standardReminders', standardReminders.map((e) => e.toJson()).toList());
    box.write('weekendStandardReminders', weekendStandardReminders.map((e) => e.toJson()).toList());
    box.write('customTimes', customTimes.map((e) => e.toJson()).toList());
  }

  void saveMode() {
    currentMode.value = tempSelectedMode.value;
    Get.back();
  }

  String get currentModeTitle {
    switch (currentMode.value) {
      case 0: return "Standard";
      case 1: return "Interval";
      case 2: return "Custom";
      default: return "Standard";
    }
  }

  void addCustomTime(BuildContext context) async {
    var newItem = CustomTime(time: "08:00 AM".obs.value);
    customTimes.add(newItem);

    ever(newItem.time, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications();});
    ever(newItem.isEnabled, (_) { _saveToDisk(); calculateNextReminder(); _updateScheduledNotifications();});

    _saveToDisk();
    calculateNextReminder();
    _updateScheduledNotifications();
  }
}
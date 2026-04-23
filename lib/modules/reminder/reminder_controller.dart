import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Bổ sung GetStorage

// ==========================================
// CÁC CLASS DỮ LIỆU ĐƯỢC NÂNG CẤP ĐỂ LƯU TRỮ
// ==========================================
class StandardReminder {
  final String name;
  final RxString time;
  final RxBool isEnabled;

  StandardReminder({required this.name, required String time, bool isEnabled = true})
      : time = time.obs,
        isEnabled = isEnabled.obs;

  // Dịch ra JSON để cất vào ổ cứng
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time.value,
    'isEnabled': isEnabled.value,
  };

  // Dịch từ JSON ra lại Data khi mở app
  factory StandardReminder.fromJson(Map<String, dynamic> json) => StandardReminder(
    name: json['name'],
    time: json['time'],
    isEnabled: json['isEnabled'],
  );
}

class CustomTime {
  final RxString time;
  final RxBool isEnabled;

  CustomTime({required String time, bool isEnabled = true})
      : time = time.obs,
        isEnabled = isEnabled.obs;

  Map<String, dynamic> toJson() => {
    'time': time.value,
    'isEnabled': isEnabled.value,
  };

  factory CustomTime.fromJson(Map<String, dynamic> json) => CustomTime(
    time: json['time'],
    isEnabled: json['isEnabled'],
  );
}

class ReminderController extends GetxController {
  final box = GetStorage(); // Hộp lưu trữ

  // 1. Công tắc tổng
  var isMasterOn = true.obs;

  // 2. Chế độ hiện tại (0: Standard, 1: Interval, 2: Custom)
  var currentMode = 0.obs;
  var tempSelectedMode = 0.obs;

  // ==========================================
  // CHẾ ĐỘ STANDARD
  // ==========================================
  final standardReminders = <StandardReminder>[].obs;

  // ==========================================
  // CHẾ ĐỘ INTERVAL
  // ==========================================
  var intervalDuration = "1 hour 30min".obs;
  var bedtimeStart = "11:00 PM".obs;
  var bedtimeEnd = "08:00 AM".obs;

  // ==========================================
  // CHẾ ĐỘ CUSTOM
  // ==========================================
  var customTimes = <CustomTime>[].obs;

  // ==========================================
  // CÀI ĐẶT CHUNG (Footer)
  // ==========================================
  var isWeekendModeOn = false.obs;
  var stopWhenGoalAchieved = true.obs;
  var isSmartSkipOn = true.obs;
  var smartSkipDuration = "1 hour".obs;

  @override
  void onInit() {
    super.onInit();
    _loadData(); // Gọi hàm load dữ liệu ngay khi mở app
    _setupAutoSave(); // Bật chế độ tự động lưu
  }

  // ==========================================
  // LOGIC LƯU TRỮ (TỰ ĐỘNG & VĨNH VIỄN)
  // ==========================================
  void _loadData() {
    isMasterOn.value = box.read('isMasterOn') ?? true;
    currentMode.value = box.read('currentMode') ?? 0;
    intervalDuration.value = box.read('intervalDuration') ?? "1 hour 30min";
    bedtimeStart.value = box.read('bedtimeStart') ?? "11:00 PM";
    bedtimeEnd.value = box.read('bedtimeEnd') ?? "08:00 AM";
    isWeekendModeOn.value = box.read('isWeekendModeOn') ?? false;
    stopWhenGoalAchieved.value = box.read('stopWhenGoalAchieved') ?? true;
    isSmartSkipOn.value = box.read('isSmartSkipOn') ?? true;
    smartSkipDuration.value = box.read('smartSkipDuration') ?? "1 hour";

    // Load list Standard
    List? storedStandard = box.read('standardReminders');
    if (storedStandard != null) {
      standardReminders.value = storedStandard.map((e) => StandardReminder.fromJson(e)).toList();
    } else {
      // Dữ liệu mặc định nếu người dùng mới cài app lần đầu
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

    // Load list Custom
    List? storedCustom = box.read('customTimes');
    if (storedCustom != null) {
      customTimes.value = storedCustom.map((e) => CustomTime.fromJson(e)).toList();
    } else {
      // Dữ liệu mặc định
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
    // Tự động lưu khi các biến cơ bản thay đổi
    everAll([
      isMasterOn, currentMode, intervalDuration, bedtimeStart, bedtimeEnd,
      isWeekendModeOn, stopWhenGoalAchieved, isSmartSkipOn, smartSkipDuration
    ], (_) => _saveToDisk());

    // Giám sát từng thẻ giờ (Standard & Custom) để tự lưu khi đổi giờ hoặc bật/tắt công tắc con
    for (var item in standardReminders) {
      ever(item.isEnabled, (_) => _saveToDisk());
      ever(item.time, (_) => _saveToDisk());
    }
    for (var item in customTimes) {
      ever(item.isEnabled, (_) => _saveToDisk());
      ever(item.time, (_) => _saveToDisk());
    }
  }

  void _saveToDisk() {
    box.write('isMasterOn', isMasterOn.value);
    box.write('currentMode', currentMode.value);
    box.write('intervalDuration', intervalDuration.value);
    box.write('bedtimeStart', bedtimeStart.value);
    box.write('bedtimeEnd', bedtimeEnd.value);
    box.write('isWeekendModeOn', isWeekendModeOn.value);
    box.write('stopWhenGoalAchieved', stopWhenGoalAchieved.value);
    box.write('isSmartSkipOn', isSmartSkipOn.value);
    box.write('smartSkipDuration', smartSkipDuration.value);

    // Lưu các List
    box.write('standardReminders', standardReminders.map((e) => e.toJson()).toList());
    box.write('customTimes', customTimes.map((e) => e.toJson()).toList());
  }

  // ==========================================
  // CÁC HÀM XỬ LÝ
  // ==========================================
  Future<void> pickTime(BuildContext context, RxString timeObs) async {
    final timeParts = timeObs.value.split(' ');
    final hm = timeParts[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (timeParts.length > 1) {
      if (timeParts[1] == 'PM' && hour < 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          // Trả lại theme sáng cho bạn đỡ bị lỗi màu nhé!
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B9CA),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hourOfPeriod == 0 ? "12" : picked.hourOfPeriod.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";
      timeObs.value = "$hourStr:$minStr $period";
      // Lưu ý: Đổi giá trị ở đây, hàm ever() ở trên sẽ tự bắt được và gọi _saveToDisk() luôn!
    }
  }

  void saveMode() {
    currentMode.value = tempSelectedMode.value;
    // Hàm ever() sẽ tự động save
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
    var newTime = "08:00 AM".obs;
    await pickTime(context, newTime);

    var newItem = CustomTime(time: newTime.value);
    customTimes.add(newItem);

    // Phải giám sát luôn cả cái item mới thêm vào này để nó tự lưu
    ever(newItem.time, (_) => _saveToDisk());
    ever(newItem.isEnabled, (_) => _saveToDisk());

    _saveToDisk(); // Update ngay lập tức xuống ổ cứng
  }
}
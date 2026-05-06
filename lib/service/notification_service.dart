import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Khởi tạo dữ liệu múi giờ
    tz.initializeTimeZones();

    // 2. Lấy múi giờ thực của thiết bị
    try {
      // Dùng var hoặc dynamic để tránh lỗi type casting "TimezoneInfo"
      final dynamic localTz = await FlutterTimezone.getLocalTimezone();
      // Nếu nó là object TimezoneInfo thì lấy .name, nếu là String thì lấy luôn
      String timeZoneName = localTz is String ? localTz : localTz.name.toString();

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback mặc định về giờ Việt Nam nếu có lỗi
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // ĐÃ SỬA LỖI 1: Bắt buộc dùng tham số có tên (initializationSettings: )
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  // Thay thế hàm cũ bằng hàm này (nhận thẳng biến DateTime)
  Future<void> scheduleDailyNotification(int id, DateTime scheduleTime) async {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'Đã đến lúc uống nước rồi! 💧',
      body: 'Hãy nạp thêm năng lượng nhé.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminders',
          channelDescription: 'Daily water drinking reminder',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
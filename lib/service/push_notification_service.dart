// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// class FCMService extends GetxService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> initializeFCM() async {
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ Notification permission granted');
//     } else {
//       print('❌ Notification permission denied');
//     }
//
//     // Lấy token FCM
//     _fetchAndSaveToken();
//
//     // Xử lý khi token thay đổi
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       print('🔄 New FCM Token: $newToken');
//       _updateTokenOnServer(newToken);
//     });
//
//     // Lắng nghe thông báo khi app đang mở
//     FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
//
//     // Lắng nghe khi người dùng nhấn vào thông báo để mở app
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedNotification);
//
//     // Xử lý thông báo khi app chạy nền
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Cấu hình thông báo cục bộ
//     _configureLocalNotifications();
//   }
//
//   Future<void> _fetchAndSaveToken() async {
//     String? fcmToken = await _firebaseMessaging.getToken();
//     if (fcmToken != null) {
//       print('🔥 FCM Token: $fcmToken');
//       _updateTokenOnServer(fcmToken);
//     }
//   }
//
//   void _updateTokenOnServer(String? token) {
//     if (token != null) {
//       print('📡 Updating FCM Token to Server: $token');
//       // Gửi token lên backend tại đây
//     }
//   }
//
//   void _handleForegroundNotification(RemoteMessage message) {
//     print('🔔 Foreground Notification: ${message.notification?.title}');
//
//     // Hiển thị thông báo cục bộ
//     _showLocalNotification(message);
//   }
//
//   void _handleOpenedNotification(RemoteMessage message) {
//     print('🔄 App opened from notification: ${message.notification?.title}');
//     // Điều hướng hoặc xử lý logic khi mở thông báo
//   }
//
//   static Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     print('🔔 Background Notification: ${message.notification?.title}');
//   }
//
//   void _configureLocalNotifications() {
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidSettings);
//
//     _localNotifications.initialize(initSettings);
//   }
//
//   void _showLocalNotification(RemoteMessage message) {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel', // ID của channel
//       'High Importance Notifications', // Tên hiển thị
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails notificationDetails =
//     NotificationDetails(android: androidDetails);
//
//     _localNotifications.show(
//       0, // ID thông báo
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//       notificationDetails,
//     );
//   }
// }

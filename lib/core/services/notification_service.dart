import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Skip notification setup on web for development
      if (kIsWeb) {
        print('Skipping notification setup on web');
        return;
      }

      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
    } catch (e) {
      print('Error initializing notifications: $e');
      // Don't throw error, just log it
    }
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request Firebase messaging permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.notification?.title}');

    // Show local notification
    await showLocalNotification(
      title: message.notification?.title ?? 'Baby Monitor',
      body: message.notification?.body ?? 'New alarm!',
      payload: message.data.toString(),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('App opened from notification: ${message.notification?.title}');
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel',
      'Baby Monitor Alarms',
      channelDescription: 'Notifications for baby monitor alarms',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

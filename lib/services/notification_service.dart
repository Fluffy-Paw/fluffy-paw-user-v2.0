import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
    FlutterLocalNotificationsPlugin();
  
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'fluffypaw_notifications',
    'FluffyPaw Notifications',
    description: 'Receive notifications about your pets and services',
    importance: Importance.high,
    enableVibration: true,
    enableLights: true,
  );

  static Future<void> initialize() async {
    // Initialize settings
    const AndroidInitializationSettings androidSettings = 
      AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings đã được cập nhật
    final DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // Không còn sử dụng onDidReceiveLocalNotification
      notificationCategories: [
        DarwinNotificationCategory(
          'basic_channel',
          actions: [
            DarwinNotificationAction.plain('open', 'Open'),
            DarwinNotificationAction.plain('dismiss', 'Dismiss'),
          ],
        ),
      ],
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationResponse(details);
      },
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationResponse,
    );

    // Create Android notification channel
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(NotificationResponse details) {
    // Handle background notification response
    _handleNotificationResponse(details);
  }

  static void _handleNotificationResponse(NotificationResponse details) {
    if (details.payload != null) {
      print('Notification payload: ${details.payload}');
      // Handle navigation or other actions based on payload
      switch (details.actionId) {
        case 'open':
          // Handle open action
          break;
        case 'dismiss':
          // Handle dismiss action
          break;
        default:
          // Handle default tap
          break;
      }
    }
  }

  static Future<bool> showNotification(PetNotification notification) async {
    if (!await checkPermission()) return false;

    try {
      await _notifications.show(
        notification.hashCode,
        notification.title,
        notification.description,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            color: notification.type.color,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'FluffyPaw',
            styleInformation: BigTextStyleInformation(
              notification.description,
              contentTitle: notification.title,
              summaryText: notification.type.name,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: notification.type.name,
            categoryIdentifier: 'basic_channel',
            threadIdentifier: notification.type.toString(),
          ),
        ),
        payload: notification.actionData,
      );
      return true;
    } catch (e) {
      print('Error showing notification: $e');
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        // Request permission
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      // For iOS, we'll use the local_notifications plugin's built-in permission check
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  static Future<void> openNotificationSettings() async {
    if (Platform.isAndroid) {
      await AppSettings.openAppSettings(
        type: AppSettingsType.notification,
      );
    } else if (Platform.isIOS) {
      await AppSettings.openAppSettings();
    }
  }

  // Thêm phương thức để lấy pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Thêm phương thức để hủy một notification cụ thể
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Thêm phương thức để hủy tất cả notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

// Thêm extension cho NotificationController
extension NotificationControllerExtension on NotificationController {
  Future<void> showLocalNotification(PetNotification notification) async {
    await NotificationService.showNotification(notification);
  }

  Future<bool> checkNotificationPermission() async {
    return await NotificationService.checkPermission();
  }

  Future<void> openNotificationSettings() async {
    await NotificationService.openNotificationSettings();
  }

  Future<void> cancelAllNotifications() async {
    await NotificationService.cancelAllNotifications();
  }
}
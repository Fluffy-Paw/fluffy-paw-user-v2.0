import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:fluffypawuser/models/notification/notification_state.dart';
import 'package:fluffypawuser/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref);
});

class NotificationController extends StateNotifier<NotificationState> {
  final Ref ref;
  HubConnection? _hubConnection;

  NotificationController(this.ref) : super(NotificationState()) {
    initializeSignalR();
  }

  Future<void> initializeSignalR() async {
    state = state.copyWith(isLoading: true);
    final token = await ref.read(hiveStoreService).getAuthToken();

    if (_hubConnection != null) {
      await _hubConnection?.stop();
      await Future.delayed(const Duration(seconds: 1));
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
            'https://fluffypaw.azurewebsites.net/NotificationHub',
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.webSockets,
              skipNegotiation: true,
            ))
        .withAutomaticReconnect([2000, 5000, 10000, 30000]).build();

    _setupConnectionHandlers();

    try {
      await _hubConnection?.start();
      state = state.copyWith(
        connectionStatus: 'Connected',
        isLoading: false,
      );
    } catch (e) {
      print('SignalR connection error: $e');
      state = state.copyWith(
        connectionStatus: 'Error',
        isLoading: false,
      );
    }
  }

  void _setupConnectionHandlers() {
    _hubConnection?.onclose((error) {
      state = state.copyWith(connectionStatus: 'Disconnected');
    });

    _hubConnection?.on('ReceiveNoti', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          // Assuming the server sends userId and message as separate arguments
          String userId = arguments[0].toString();
          String message = arguments[1].toString();

          // Parse message content - assuming it's a notification title
          // You may need to adjust this based on your actual message format
          final newNotification = PetNotification(
            title: "New Notification",
            description: message,
            time: DateTime.now(),
            type: _determineNotificationType(
                message), // Helper method to determine type
            isRead: false,
          );
          showLocalNotification(newNotification);

          state = state.copyWith(
            notifications: [newNotification, ...state.notifications],
          );
        } catch (e) {
          print('Error handling notification: $e');
        }
      }
    });
  }

  NotificationType _determineNotificationType(String message) {
    message = message.toLowerCase();

    if (message.contains('service') || message.contains('maintenance')) {
      return NotificationType.service;
    } else if (message.contains('store') || message.contains('shop')) {
      return NotificationType.store;
    } else if (message.contains('booking') || message.contains('appointment')) {
      return NotificationType.booking;
    } else if (message.contains('vaccine') || message.contains('vaccination')) {
      return NotificationType.vaccine;
    } else if (message.contains('withdraw') || message.contains('payment')) {
      return NotificationType.withdraw;
    } else if (message.contains('check in') || message.contains('checkin')) {
      return NotificationType.checkin;
    } else if (message.contains('check out') || message.contains('checkout')) {
      return NotificationType.checkout;
    } else {
      return NotificationType.message;
    }
  }

  void markAsRead(String id) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.title == id) {
        // Assuming title is used as ID
        return PetNotification(
          title: notification.title,
          description: notification.description,
          time: notification.time,
          type: notification.type,
          actionData: notification.actionData,
          isRead: true,
        );
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void deleteNotification(String id) {
    final updatedNotifications = state.notifications
        .where((notification) =>
            notification.title != id) // Assuming title is used as ID
        .toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void clearAllNotifications() {
    state = state.copyWith(notifications: []);
  }

  void setFilter(NotificationType? type) {
    state = state.copyWith(selectedFilter: type);
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return PetNotification(
        title: notification.title,
        description: notification.description,
        time: notification.time,
        type: notification.type,
        actionData: notification.actionData,
        isRead: true,
      );
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  // Get unread count for a specific type
  int getUnreadCount(NotificationType? type) {
    if (type == null) {
      return state.notifications.where((n) => !n.isRead).length;
    }
    return state.notifications.where((n) => !n.isRead && n.type == type).length;
  }

  // Get notifications count by type
  int getNotificationCount(NotificationType? type) {
    if (type == null) return state.notifications.length;
    return state.notifications.where((n) => n.type == type).length;
  }

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }
}

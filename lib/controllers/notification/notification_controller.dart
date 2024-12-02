import 'dart:convert';

import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/notification/noti.dart';
import 'package:fluffypawuser/models/notification/notification_event.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:fluffypawuser/models/notification/notification_state.dart';
import 'package:fluffypawuser/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/http.dart' as http;

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref);
});

class NotificationController extends StateNotifier<NotificationState> {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;

  NotificationController(this.ref) : super(NotificationState()) {
    // Initialize by fetching notifications
    fetchNotifications();
  }
  Future<void> fetchNotifications() async {
    try {
      state = state.copyWith(isLoading: true);
      final token = await ref.read(hiveStoreService).getAuthToken();

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication token not found',
        );
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://fluffypaw.azurewebsites.net/api/Notification/GetNotification?numberNoti=1000'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> data = responseData['data'];
        final List<dynamic> items = data['items'];
        final notifications = items
            .map((json) => NotificationMapper.fromApiResponse(json))
            .toList();
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error fetching notifications: $e',
      );
    }
  }

  Future<void> initializeSignalR() async {
    try {
      print('SignalR: Start connection attempt');

      // Check if already connected
      if (_hubConnection?.state == HubConnectionState.connected) {
        print('SignalR: Already connected');
        return;
      }

      // Check if connection attempt is in progress
      if (_isConnecting) {
        print('SignalR: Connection attempt already in progress');
        return;
      }

      _isConnecting = true;
      state = state.copyWith(isLoading: true);

      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) {
        print('SignalR: No auth token found');
        _isConnecting = false;
        state = state.copyWith(
          isLoading: false,
          connectionStatus: 'Disconnected',
        );
        return;
      }

      print('SignalR: Creating new connection');
      _hubConnection = HubConnectionBuilder()
          .withUrl(
              'https://fluffypaw.azurewebsites.net/NotificationHub',
              HttpConnectionOptions(
                accessTokenFactory: () async => token,
                transport: HttpTransportType.webSockets,
                skipNegotiation: true,
                logging: (level, message) => print('SignalR Log: $message'),
              ))
          .withAutomaticReconnect([0, 2000, 10000, 30000]).build();

      _setupConnectionHandlers();

      try {
        await _hubConnection?.start();
        print('SignalR: Connected successfully');
        state = state.copyWith(
          isLoading: false,
          connectionStatus: 'Connected',
        );
      } catch (e) {
        print('SignalR: Error starting connection: $e');
        state = state.copyWith(
          isLoading: false,
          connectionStatus: 'Error',
        );
        rethrow;
      } finally {
        _isConnecting = false;
      }
    } catch (e) {
      _isConnecting = false;
      print('SignalR Error: $e');
      state = state.copyWith(
        isLoading: false,
        connectionStatus: 'Error',
      );
    }
  }

  void _setupConnectionHandlers() {
    _hubConnection?.onclose((error) {
      print('SignalR: Connection closed, error: $error');
      state = state.copyWith(connectionStatus: 'Disconnected');
    });

    _hubConnection?.onreconnecting((_) {
      print('SignalR: Attempting to reconnect...');
      state = state.copyWith(connectionStatus: 'Reconnecting');
    });

    _hubConnection?.onreconnected((_) {
      print('SignalR: Reconnected successfully');
      state = state.copyWith(connectionStatus: 'Connected');
    });

    _hubConnection?.on('ReceiveNoti', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          print('SignalR: Received notification: $arguments');
          String userId = arguments[0].toString();
          String message = arguments[1].toString();
          //int bookingId = int.tryParse(arguments[3]?.toString() ?? '0') ?? 0;

          String notificationType = arguments[2]?.toString() ?? '';
          int bookingId = int.tryParse(arguments[3]?.toString() ?? '0') ?? 0;

          NotificationEvent event = NotificationEvent(
              message: message,
              type: _determineNotificationType(notificationType),
              bookingId: bookingId);
          eventBus.fire(event);

          final newNotification = PetNotification(
            title: "New Notification",
            description: message,
            time: DateTime.now(),
            type: _determineNotificationType(message),
            isRead: false,
          );

          showLocalNotification(newNotification);

          state = state.copyWith(
            notifications: [newNotification, ...state.notifications],
          );
          print('SignalR: Notification processed successfully');
        } catch (e) {
          print('SignalR: Error handling notification: $e');
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
        .where((notification) => notification.title != id)
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

  int getUnreadCount(NotificationType? type) {
    if (type == null) {
      return state.notifications.where((n) => !n.isRead).length;
    }
    return state.notifications.where((n) => !n.isRead && n.type == type).length;
  }

  int getNotificationCount(NotificationType? type) {
    if (type == null) return state.notifications.length;
    return state.notifications.where((n) => n.type == type).length;
  }

  String getConnectionStatus() {
    return state.connectionStatus;
  }
}

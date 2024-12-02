
import 'package:fluffypawuser/models/notification/notification_model.dart';

class NotificationState {
  final List<PetNotification> notifications;
  final String connectionStatus;
  final bool isLoading;
  final String? error;
  final NotificationType? selectedFilter;

  NotificationState({
    this.notifications = const [],
    this.connectionStatus = 'Disconnected',
    this.isLoading = true,
    this.selectedFilter,
    this.error,
  });

  NotificationState copyWith({
    List<PetNotification>? notifications,
    String? connectionStatus,
    String? error,
    bool? isLoading,
    NotificationType? selectedFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      error: error,
    );
  }

  List<PetNotification> get filteredNotifications {
    if (selectedFilter == null) return notifications;
    return notifications.where((notification) => 
      notification.type == selectedFilter
    ).toList();
  }
}
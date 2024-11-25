
import 'package:fluffypawuser/models/notification/notification_model.dart';

class NotificationState {
  final List<PetNotification> notifications;
  final String connectionStatus;
  final bool isLoading;
  final NotificationType? selectedFilter;

  NotificationState({
    this.notifications = const [],
    this.connectionStatus = 'Disconnected',
    this.isLoading = true,
    this.selectedFilter,
  });

  NotificationState copyWith({
    List<PetNotification>? notifications,
    String? connectionStatus,
    bool? isLoading,
    NotificationType? selectedFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<PetNotification> get filteredNotifications {
    if (selectedFilter == null) return notifications;
    return notifications.where((notification) => 
      notification.type == selectedFilter
    ).toList();
  }
}
import 'package:fluffypawuser/models/notification/notification_model.dart';

class NotificationMapper {
  static NotificationType mapApiTypeToEnum(String type) {
    switch (type.toLowerCase()) {
      case 'khách sạn':
        return NotificationType.service;
      case 'booking':
        return NotificationType.booking;
      case 'checkin':
        return NotificationType.checkin;
      case 'checkout':
        return NotificationType.checkout;
      default:
        return NotificationType.message;
    }
  }

  static PetNotification fromApiResponse(Map<String, dynamic> json) {
    return PetNotification(
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      time: DateTime.parse(json['createDate'] ?? DateTime.now().toIso8601String()),
      type: mapApiTypeToEnum(json['type']),
      actionData: json['referenceId']?.toString(),
      isRead: json['isSeen'] ?? false,
    );
  }
}
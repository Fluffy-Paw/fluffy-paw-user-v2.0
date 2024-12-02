import 'package:event_bus/event_bus.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';

final eventBus = EventBus();

class NotificationEvent {
  final String message;
  final NotificationType type;
  final int? bookingId;

  NotificationEvent({
    required this.message,
    required this.type,
    this.bookingId,
  });

  // Extract booking ID from notification message if possible
  factory NotificationEvent.fromMessage(String message, NotificationType type) {
    final RegExp regExp = RegExp(r'#(\d+)');
    final match = regExp.firstMatch(message);
    final bookingId = match != null ? int.tryParse(match.group(1) ?? '') : null;
    
    return NotificationEvent(
      message: message,
      type: type,
      bookingId: bookingId,
    );
  }

  bool isRelevantFor(int bookingId) {
    return this.bookingId == bookingId;
  }
}


import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends ConsumerWidget {
  final PetNotification notification;
  final int index;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(notification.title), // Using title as unique identifier
      background: _buildDismissBackground(true),
      secondaryBackground: _buildDismissBackground(false),
      onDismissed: (direction) {
        ref.read(notificationControllerProvider.notifier)
           .deleteNotification(notification.title);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: notification.isRead ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead 
              ? BorderSide(color: Colors.grey.shade200)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notification.isRead) {
              ref.read(notificationControllerProvider.notifier)
                 .markAsRead(notification.title);
            }
            _handleNotificationTap(context);
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: notification.type.color,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeago.format(notification.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (notification.actionData != null)
                            TextButton(
                              onPressed: () => _handleActionTap(context),
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  color: notification.type.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        notification.type.icon,
        color: notification.type.color,
        size: 24,
      ),
    );
  }

  Widget _buildDismissBackground(bool isStart) {
    return Container(
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
    );
  }

  void _handleNotificationTap(BuildContext context) {
    // Handle notification tap based on type and actionData
    if (notification.actionData != null) {
      // Navigate or perform action based on actionData
    }
  }

  void _handleActionTap(BuildContext context) {
    if (notification.actionData != null) {
      // Handle specific action based on notification type
      switch (notification.type) {
        case NotificationType.booking:
          // Navigate to booking details
          break;
        case NotificationType.service:
          // Navigate to service details
          break;
        default:
          break;
      }
    }
  }
}
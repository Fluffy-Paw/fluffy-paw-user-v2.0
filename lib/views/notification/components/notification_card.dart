

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
      key: Key(notification.title),
      background: _buildDismissibleBackground(true),
      secondaryBackground: _buildDismissibleBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          ref.read(notificationControllerProvider.notifier)
            .deleteNotification(notification.title);
        } else {
          ref.read(notificationControllerProvider.notifier)
            .markAsRead(notification.title);
        }
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide(color: Colors.grey.shade200)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: notification.type.color.withOpacity(0.1),
            child: Icon(
              notification.type.icon,
              color: notification.type.color,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                  ),
                ),
              ),
              Text(
                timeago.format(notification.time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                notification.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              if (notification.actionData != null) ...[
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Handle action
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: notification.type.color,
                    side: BorderSide(color: notification.type.color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground(bool isLeft) {
    return Container(
      color: isLeft ? Colors.blue.shade100 : Colors.red.shade100,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        isLeft ? Icons.check : Icons.delete,
        color: isLeft ? Colors.blue.shade700 : Colors.red.shade700,
      ),
    );
  }
}
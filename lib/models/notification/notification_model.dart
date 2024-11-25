// lib/data/models/notification/notification_model.dart

import 'package:flutter/material.dart';

enum NotificationType {
  service,   // Các thông báo liên quan đến dịch vụ
  store,     // Thông báo từ cửa hàng
  booking,   // Thông báo đặt lịch
  vaccine,   // Nhắc nhở tiêm vaccine
  withdraw,  // Thông báo rút tiền
  message,
  checkin,
  checkout
}

class PetNotification {
  final String title;
  final String description;
  final DateTime time;
  final NotificationType type;
  final String? actionData;
  bool isRead;

  PetNotification({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.actionData,
    this.isRead = false,
  });

  factory PetNotification.fromJson(Map<String, dynamic> json) {
    return PetNotification(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.message,
      ),
      actionData: json['actionData'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'type': type.toString().split('.').last,
      'actionData': actionData,
      'isRead': isRead,
    };
  }
}

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.service:
        return Icons.room_service;
      case NotificationType.store:
        return Icons.store;
      case NotificationType.booking:
        return Icons.calendar_today;
      case NotificationType.vaccine:
        return Icons.medical_services;
      case NotificationType.withdraw:
        return Icons.account_balance_wallet;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.checkin:
        return Icons.login;
      case NotificationType.checkout:
        return Icons.logout;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.service:
        return Colors.purple;
      case NotificationType.store:
        return Colors.blue;
      case NotificationType.booking:
        return Colors.green;
      case NotificationType.vaccine:
        return Colors.orange;
      case NotificationType.withdraw:
        return Colors.teal;
      case NotificationType.message:
        return Colors.indigo;
      case NotificationType.checkin:
        return Colors.green;
      case NotificationType.checkout:
        return Colors.green;
    }
  }
}
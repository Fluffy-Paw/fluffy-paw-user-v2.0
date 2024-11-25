import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color? primaryColor;
  final Color? accentColor;
  final Color? buttonColor;
  final Color? headingColor;
  final Color? bodyTextColor;
  final Color? bodyTextSmallColor;
  final Color? hintTextColor;

  const AppColors({
    required this.primaryColor,
    required this.accentColor,
    required this.buttonColor,
    this.headingColor,
    required this.bodyTextColor,
    required this.bodyTextSmallColor,
    required this.hintTextColor,
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? buttonColor,
    Color? headingColor,
    Color? bodyTextColor,
    Color? bodyTextSmallColor,
    Color? titleTextColor,
    Color? hintTextColor,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      buttonColor: buttonColor ?? this.buttonColor,
      headingColor: headingColor ?? this.headingColor,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      bodyTextSmallColor: bodyTextSmallColor ?? this.bodyTextSmallColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t),
      headingColor: Color.lerp(headingColor, other.headingColor, t),
      bodyTextColor: Color.lerp(bodyTextColor, other.bodyTextColor, t),
      bodyTextSmallColor:
      Color.lerp(bodyTextSmallColor, other.bodyTextSmallColor, t),
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t),
    );
  }
}

class AppColor {
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color offWhiteColor = Color(0xFFF3F4F6);
  static const Color blackColor = Color(0xFF111827);
  static const Color violetColor = Color(0xFFA259FF);
  static const Color violet100 = Color(0xFFe8d5ff);
  static const Color redColor = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color lime500 = Color(0xFF3BD804);
  static const Color lime100 = Color(0xFFECFCCB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color greyColor = Color(0xFF9E9E9E); 

  // Colors of status card

  static const Color pending = Color(0xFFF59E0B);
  static const Color pikingUp = Color(0xFF773BF6);
  static const Color processing = Color(0xFF3B82F6);
  static const Color delivering = Color(0xFFF529C8);
  static const Color delivered = Color(0xFF3BD804);

  // Booking status colors
  static const Color bookingPending = amber500;      
  static const Color bookingAccepted = lime500;      
  static const Color bookingOvertime = violetColor;  
  static const Color bookingEnded = blue500;         
  static const Color bookingCanceled = redColor;

  // Background colors for booking status (opacity 0.12)
  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return bookingPending.withOpacity(0.12);
      case 'accepted':
        return bookingAccepted.withOpacity(0.12);
      case 'overtime':
        return bookingOvertime.withOpacity(0.12);
      case 'ended':
        return bookingEnded.withOpacity(0.12);
      case 'canceled':
        return bookingCanceled.withOpacity(0.12);
      default:
        return greyColor.withOpacity(0.12);
    }
  }

  // Booking status list for filters
  static final List<Map<String, dynamic>> bookingStatusFilters = [
    {
      'id': 'all',
      'label': 'Tất cả',
      'icon': Icons.all_inbox,
      'color': violetColor
    },
    {
      'id': 'pending',
      'label': 'Chờ xác nhận',
      'icon': Icons.pending_outlined,
      'color': bookingPending
    },
    {
      'id': 'accepted',
      'label': 'Đã xác nhận',
      'icon': Icons.check_circle_outline,
      'color': bookingAccepted
    },
    {
      'id': 'overtime',
      'label': 'Quá giờ',
      'icon': Icons.timer_off_outlined,
      'color': bookingOvertime
    },
    {
      'id': 'ended',
      'label': 'Đã kết thúc',
      'icon': Icons.task_alt,
      'color': bookingEnded
    },
    {
      'id': 'canceled',
      'label': 'Đã hủy',
      'icon': Icons.cancel_outlined,
      'color': bookingCanceled
    },
  ];
}

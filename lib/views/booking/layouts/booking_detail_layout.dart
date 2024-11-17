import 'dart:convert';

import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/models/booking/booking_model.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetailLayout extends ConsumerStatefulWidget {
  final BookingModel booking;

  const BookingDetailLayout({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  ConsumerState<BookingDetailLayout> createState() =>
      _BookingDetailLayoutState();
}

class _BookingDetailLayoutState extends ConsumerState<BookingDetailLayout> {
  bool _isCancelling = false;
  bool _isLoading = false;

  Future<bool?> _showCancelConfirmation() async {
    return showDialog<bool>(
      // Specify return type as bool
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Xác nhận hủy đặt lịch',
            style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn hủy đặt lịch này không? Hành động này không thể hoàn tác.',
            style: AppTextStyle(context).bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Return false
              child: Text(
                'Không',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Return true
              child: Text(
                'Có, hủy đặt lịch',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);

    try {
      await ref.read(storeController.notifier).cancelBooking(widget.booking.id);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã hủy đặt lịch thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

        // Pop back to booking history with refresh flag
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
              ? AppColor.blackColor
              : AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chi tiết đặt lịch',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Status Card
                _buildStatusCard(),
                _buildCheckInOutStatus(),

                // Service Details
                _buildSectionCard(
                  'Thông tin dịch vụ',
                  [
                    _buildInfoRow(
                      'Cửa hàng',
                      widget.booking.storeName,
                      icon: Icons.store,
                    ),
                    _buildInfoRow(
                      'Dịch vụ',
                      widget.booking.serviceName,
                      icon: Icons.pets,
                    ),
                    _buildInfoRow(
                      'Địa chỉ',
                      widget.booking.address,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),

                // Time Details
                _buildSectionCard(
                  'Thông tin thời gian',
                  [
                    _buildInfoRow(
                      'Ngày đặt',
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(widget.booking.createDate),
                      icon: Icons.event_note,
                    ),
                    _buildInfoRow(
                      'Thời gian bắt đầu',
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(widget.booking.startTime),
                      icon: Icons.schedule,
                    ),
                    _buildInfoRow(
                      'Thời gian kết thúc',
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(widget.booking.endTime),
                      icon: Icons.timer_off,
                    ),
                  ],
                ),

                // Check-in/out Details
                if (widget.booking.checkin || widget.booking.checkout)
                  _buildSectionCard(
                    'Thông tin Check-in/out',
                    [
                      if (widget.booking.checkin)
                        _buildInfoRow(
                          'Check-in',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(widget.booking.checkinTime),
                          icon: Icons.login,
                          iconColor: Colors.green,
                        ),
                      if (widget.booking.checkout &&
                          widget.booking.checkOutTime != null)
                        _buildInfoRow(
                          'Check-out',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(widget.booking.checkOutTime!),
                          icon: Icons.logout,
                          iconColor: Colors.red,
                        ),
                    ],
                  ),

                // Payment Details
                _buildSectionCard(
                  'Thông tin thanh toán',
                  [
                    _buildInfoRow(
                      'Phương thức',
                      widget.booking.paymentMethod,
                      icon: Icons.payment,
                    ),
                    _buildInfoRow(
                      'Tổng tiền',
                      '${NumberFormat('#,###', 'vi_VN').format(widget.booking.cost)}đ',
                      icon: Icons.monetization_on,
                      valueStyle: AppTextStyle(context).title.copyWith(
                            color: AppColor.violetColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),

                // Additional Info
                if (widget.booking.description.isNotEmpty)
                  _buildSectionCard(
                    'Ghi chú',
                    [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          widget.booking.description,
                          style: AppTextStyle(context).bodyText.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ),
                    ],
                  ),

                // Extra space for the button
                Gap(100.h),
              ],
            ),
          ),

          // Cancel Button
          if (widget.booking.status.toLowerCase() == 'pending')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isCancelling
                      ? null
                      : () async {
                          final shouldCancel = await _showCancelConfirmation();
                          if (shouldCancel == true) {
                            await _cancelBooking();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isCancelling
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Hủy đặt lịch',
                          style: AppTextStyle(context).buttonText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              ),
            ),
          if (widget.booking.status.toLowerCase() == 'pending')
            _buildCancelButton()
          else if (widget.booking.status.toLowerCase() == 'accepted' &&
              !widget.booking.checkin)
            _buildActionButton(
              'Check-in',
              Colors.green,
              () => _generateQRCode('Checkin', widget.booking.id),
            )
          else if (widget.booking.checkin && !widget.booking.checkout)
            _buildDualActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AppTextStyle(context).buttonText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }

  Widget _buildDualActionButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tracking Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Add tracking functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.violetColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Tracking',
                  style: AppTextStyle(context).buttonText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Gap(12.w), // Add spacing between buttons
            // Check-out Button
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _generateQRCode('Checkout', widget.booking.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Check-out',
                        style: AppTextStyle(context).buttonText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isCancelling
              ? null
              : () async {
                  final shouldCancel = await _showCancelConfirmation();
                  if (shouldCancel == true) {
                    await _cancelBooking();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: _isCancelling
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Hủy đặt lịch',
                  style: AppTextStyle(context).buttonText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (widget.booking.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hoàn thành';
        statusDescription = 'Dịch vụ đã được hoàn thành thành công';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        statusDescription = 'Lịch đặt đã bị hủy';
        break;
      case 'pending':
        statusColor = AppColor.violetColor;
        statusIcon = Icons.schedule;
        statusText = 'Đang chờ';
        statusDescription = 'Đang chờ xác nhận từ cửa hàng';
        break;
      default:
        statusColor = AppColor.violetColor;
        statusIcon = Icons.info;
        statusText = widget.booking.status;
        statusDescription = 'Trạng thái: ${widget.booking.status}';
    }

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 32.sp,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTextStyle(context).title.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                ),
                Gap(4.h),
                Text(
                  statusDescription,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
          ),
          Gap(12.h),
          ...children,
        ],
      ),
    );
  }

  void _generateQRCode(String endpoint, int bookingId) {
    final apiUrl = 'https://fluffypaw.azurewebsites.net/api/Booking/$endpoint';
    final requestBody = {
      "id": [bookingId]
    };

    final qrData = jsonEncode(
        {'url': apiUrl, 'data': requestBody, 'requiresStaffAuth': true});

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  endpoint == 'Checkin'
                      ? Icons.login_rounded
                      : Icons.logout_rounded,
                  color: AppColor.violetColor,
                  size: 32.sp,
                ),
              ),
              Gap(16.h),
              Text(
                endpoint == 'Checkin' ? 'Check-in' : 'Check-out',
                style: AppTextStyle(context).title.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.violetColor,
                    ),
              ),
              Gap(8.h),
              Text(
                'Vui lòng đưa mã QR này cho nhân viên quét',
                textAlign: TextAlign.center,
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Gap(24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.w,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColor.violetColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColor.violetColor,
                  ),
                ),
              ),
              Gap(24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Đóng',
                        style: AppTextStyle(context).buttonText.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInOutStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái Check-in/out',
            style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
          ),
          Gap(12.h),
          _buildInfoRow(
            'Check-in',
            widget.booking.checkin ? 'Đã check-in' : 'Chưa check-in',
            icon: Icons.login,
            iconColor: widget.booking.checkin ? Colors.green : Colors.grey,
          ),
          _buildInfoRow(
            'Check-out',
            widget.booking.checkout ? 'Đã check-out' : 'Chưa check-out',
            icon: Icons.logout,
            iconColor: widget.booking.checkout ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20.sp,
              color: iconColor ?? Colors.grey[600],
            ),
            Gap(12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Gap(4.h),
                Text(
                  value,
                  style: valueStyle ??
                      AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[800],
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_model.dart';
import 'package:fluffypawuser/models/notification/notification_event.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:fluffypawuser/views/report/report_screen.dart';
import 'package:fluffypawuser/views/tracking/tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailLayout extends ConsumerStatefulWidget {
  // final BookingModel booking;
  final int bookingId;

  const BookingDetailLayout(
      {Key? key,
      //required this.booking,
      required this.bookingId})
      : super(key: key);

  @override
  ConsumerState<BookingDetailLayout> createState() =>
      _BookingDetailLayoutState();
}

class _BookingDetailLayoutState extends ConsumerState<BookingDetailLayout> {
  StreamSubscription? _notificationSubscription;
  bool _isCancelling = false;
  bool _isLoading = true;
  Timer? _countdownTimer;
  Duration? _timeUntilService;
  Timer? _serviceTimer;
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    Future(() => _loadBookingDetails()); // Delay initialization
    _subscribeToNotifications();
  }

  // void _subscribeToNotifications() {
  //   _notificationSubscription =
  //       eventBus.on<NotificationEvent>().listen((event) async {
  //     print("Received notification for booking ${event.bookingId}");
  //     if (event.bookingId == _booking.id) {
  //       // Close QR dialog first
  //       if (mounted) {
  //         Navigator.of(context).pop();
  //         setState(() => _isLoading = true);
  //       }

  //       try {
  //         // Get updated booking data
  //         final updatedBooking = await ref
  //             .read(storeController.notifier)
  //             .getBookingById(_booking.id);

  //         // Update both local state and store controller
  //         if (mounted && updatedBooking != null) {
  //           setState(() {
  //             _booking = updatedBooking;
  //             _isLoading = false;
  //           });

  //           // Force store controller refresh
  //           ref.invalidate(storeController);

  //           // Update booking list in background
  //           await ref.read(storeController.notifier).getAllBookings();

  //           // Final UI update
  //           if (mounted) {
  //             setState(() {});
  //           }
  //         }
  //       } catch (e) {
  //         print("Error updating booking: $e");
  //         if (mounted) {
  //           setState(() => _isLoading = false);
  //         }
  //       }
  //     }
  //   });
  // }
  void _subscribeToNotifications() {
    _notificationSubscription =
        eventBus.on<NotificationEvent>().listen((event) async {
      if (event.bookingId == widget.bookingId) {
        // Close QR dialog if open
        Navigator.of(context).pop();
        await _loadBookingDetails();
      }
    });
  }

  Future<void> _loadBookingDetails() async {
    try {
      final booking = await ref
          .read(storeController.notifier)
          .getBookingById(widget.bookingId);
      if (mounted && booking != null) {
        setState(() {
          _booking = booking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _startTimers() {
    // Cập nhật thời gian đếm ngược đến giờ phục vụ
    _updateServiceCountdown();
    _serviceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateServiceCountdown();
    });
  }

  void _updateServiceCountdown() {
    final now = DateTime.now();
    if (now.isBefore(_booking!.startTime)) {
      setState(() {
        _timeUntilService = _booking?.startTime.difference(now);
      });
    } else {
      _serviceTimer?.cancel();
      setState(() {
        _timeUntilService = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: _isLoading
          ? _buildLoadingView()
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    if (_booking != null)
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildStatusCard(),
                            if (_timeUntilService != null)
                              _buildCountdownCard(),
                            _buildBookingProgress(),
                            _buildServiceDetailsCard(),
                            _buildPetInfoCard(),
                            _buildPaymentCard(),
                            _buildLocationCard(),
                            _buildImagesSection(),
                            SizedBox(height: 50.h),
                          ],
                        ),
                      ),
                  ],
                ),
                if (_booking != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomActionBar(),
                  ),
              ],
            ),
    );
  }

  // Widget _buildLoadingView() {
  //   return Shimmer.fromColors(
  //     baseColor: Colors.grey[300]!,
  //     highlightColor: Colors.grey[100]!,
  //     child: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           AppBar(backgroundColor: Colors.white),
  //           ...List.generate(
  //               4,
  //               (index) => Container(
  //                     margin: EdgeInsets.all(16.w),
  //                     height: 120.h,
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(16.r),
  //                     ),
  //                   )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

// // Example method updated to use _booking
//   Widget _buildStatusCard() {
//     final statusInfo = _getStatusInfo(_booking.status);

//     // ... rest of the method
//   }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColor.whiteColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Chi tiết đặt lịch #${_booking?.code}',
        style: AppTextStyle(context).title.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, size: 20.sp),
          onPressed: _shareBookingDetails,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    if (_booking == null) return const SizedBox.shrink();
    final statusInfo = _getStatusInfo(_booking!.status);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusInfo.icon,
                  color: statusInfo.color,
                  size: 24.sp,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo.text,
                      style: AppTextStyle(context).title.copyWith(
                            color: statusInfo.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Gap(4.h),
                    Text(
                      statusInfo.description,
                      style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_booking!.description.isNotEmpty) ...[
            Gap(12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20.sp, color: Colors.grey[600]),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      _booking!.description,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[800],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    final hours = _timeUntilService?.inHours ?? 0;
    final minutes = (_timeUntilService?.inMinutes ?? 0) % 60;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.violetColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: AppColor.violetColor, size: 24.sp),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian còn lại',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.violetColor,
                      ),
                ),
                Text(
                  '$hours giờ $minutes phút',
                  style: AppTextStyle(context).title.copyWith(
                        color: AppColor.violetColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingProgress() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến trình đặt lịch',
            style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Gap(16.h),
          _buildProgressStep(
            title: 'Đặt lịch',
            time: _formatDateTime(_booking!.createDate),
            isCompleted: true,
            isFirst: true,
          ),
          _buildProgressStep(
            title: 'Check-in',
            time: _booking?.checkinTime != null
                ? _formatDateTime(_booking!.checkinTime!)
                : null,
            isCompleted: _booking!.checkin,
          ),
          _buildProgressStep(
            title: 'Check-out',
            time: _booking?.checkOutTime != null
                ? _formatDateTime(_booking!.checkOutTime!)
                : null,
            isCompleted: _booking!.checkout,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    String? time,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline
          if (!isFirst)
            Padding(
              padding: EdgeInsets.only(left: 11.w),
              child: VerticalDivider(
                color: isCompleted ? AppColor.violetColor : Colors.grey[300],
                thickness: 2,
              ),
            ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color:
                          isCompleted ? AppColor.violetColor : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? AppColor.blackColor
                                    : Colors.grey[600],
                              ),
                        ),
                        if (time != null) ...[
                          Gap(4.h),
                          Text(
                            time,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    final serviceDuration = _booking?.endTime.difference(_booking!.startTime);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.miscellaneous_services, color: AppColor.violetColor),
              Gap(8.w),
              Text(
                'Chi tiết dịch vụ',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(16.h),
          _buildInfoRow(
            'Tên dịch vụ',
            _booking!.serviceName,
          ),
          _buildInfoRow(
            'Cửa hàng',
            _booking!.storeName,
          ),
          _buildInfoRow(
            'Thời gian bắt đầu',
            _formatDateTime(_booking!.startTime),
          ),
          _buildInfoRow(
            'Thời gian kết thúc',
            _formatDateTime(_booking!.endTime),
          ),
          _buildInfoRow(
            'Thời lượng',
            '${serviceDuration?.inMinutes} phút',
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: AppColor.violetColor),
              Gap(8.w),
              Text(
                'Thông tin thú cưng',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  color: AppColor.violetColor,
                  size: 32.sp,
                ),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _booking!.petName,
                      style: AppTextStyle(context).title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'ID: #${_booking?.petId}',
                      // Tiếp tục từ _buildPetInfoCard
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColor.violetColor),
              Gap(8.w),
              Text(
                'Thông tin thanh toán',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phương thức thanh toán',
                style: AppTextStyle(context).bodyText,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _booking!.paymentMethod,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.violetColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền',
                style: AppTextStyle(context).bodyText,
              ),
              Text(
                currencyFormatter.format(_booking?.cost),
                style: AppTextStyle(context).title.copyWith(
                      color: AppColor.violetColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColor.violetColor),
              Gap(8.w),
              Text(
                'Địa điểm',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.store_outlined,
                color: Colors.grey[600],
                size: 20.sp,
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  _booking!.address,
                  style: AppTextStyle(context).bodyText,
                ),
              ),
            ],
          ),
          Gap(12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openMap,
              icon: Icon(
                Icons.directions,
                size: 20.sp,
              ),
              label: Text('Chỉ đường'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_booking?.checkinImage != null)
          _buildImageCard(
            'Ảnh check-in',
            _booking!.checkinImage!,
            _booking!.checkinTime!,
          ),
        if (_booking?.checkoutImage != null)
          _buildImageCard(
            'Ảnh check-out',
            _booking!.checkoutImage!,
            _booking!.checkOutTime!,
          ),
      ],
    );
  }

  Widget _buildImageCard(String title, String imageUrl, DateTime time) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: AppColor.violetColor),
              Gap(8.w),
              Text(
                title,
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(8.h),
          Text(
            _formatDateTime(time),
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Gap(12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.error, size: 40.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    if (_booking == null) return const SizedBox.shrink();
    final status = _booking?.status.toLowerCase();

    if (status == 'pending') {
      return _buildCancelButton();
    }
    if (status == 'overtime' || status == 'canceled') {
      return _buildReportButton();
    }

    if (status == 'accepted' && !_booking!.checkin) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _generateQRCode('Checkin', _booking!.id),
                      icon: Icon(Icons.login_rounded, size: 18.sp),
                      label: Text(
                        'Check-in ngay',
                        style: AppTextStyle(context).buttonText.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                _buildReportButton(isSmall: true),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              _buildReportButton(isSmall: true),
              Gap(12.w),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackingScreen(bookingId: _booking!.id),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.map_outlined,
                    size: 18.sp,
                    color: AppColor.violetColor,
                  ),
                  label: Text(
                    'Xem hành trình',
                    style: AppTextStyle(context).buttonText.copyWith(
                          color: AppColor.violetColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.violetColor.withOpacity(0.1),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: AppColor.violetColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (!_booking!.checkout) ...[
                Gap(12.w),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQRCode('Checkout', _booking!.id),
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Check-out',
                      style: AppTextStyle(context).buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.violetColor,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton({bool isSmall = false}) {
    return SizedBox(
      width: isSmall ? 44.h : double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportScreen(targetId: _booking!.id),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isSmall 
          ? Icon(Icons.report_problem_outlined, size: 18.sp, color: Colors.red[700])
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.report_problem_outlined, size: 18.sp, color: Colors.red[700]),
                Gap(8.w),
                Text(
                  'Báo cáo',
                  style: AppTextStyle(context).buttonText.copyWith(
                    color: Colors.red[700],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  void _generateQRCode(String endpoint, int bookingId) {
    final String capitalizedEndpoint = endpoint.substring(0, 1).toUpperCase() +
        endpoint.substring(1).toLowerCase();
    final apiUrl =
        'https://fluffypaw.azurewebsites.net/api/Booking/$capitalizedEndpoint';

    final requestBody = {
      "id": [bookingId],
      "requireImageUpload": true,
    };

    if (endpoint.toLowerCase() == 'checkout') {
      requestBody.addAll({
        "requiresMultipleImages": true,
        "imageFields": ["CheckoutImage", "Image"],
        "additionalFields": {
          "Name": {"type": "string", "required": true},
          "PetCurrentWeight": {"type": "number", "required": true},
          "NextVaccineDate": {"type": "date", "required": true},
          "Description": {"type": "string", "required": false}
        }
      });
    } else {
      requestBody["imageField"] = "CheckinImage";
    }

    final qrData = jsonEncode(
        {'url': apiUrl, 'data': requestBody, 'requiresStaffAuth': true});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
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
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Chỉ đóng dialog
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
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
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      color: AppColor.whiteColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: _isCancelling ? null : _showCancelConfirmation,
              icon: _isCancelling
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : Icon(
                      Icons.cancel_outlined,
                      size: 18.sp,
                      color: Colors.red,
                    ),
              label: Text(
                'Hủy đặt lịch',
                style: AppTextStyle(context).buttonText.copyWith(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
  }

  StatusInfo _getStatusInfo(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'pending':
        return StatusInfo(
          color: Colors.orange,
          icon: Icons.schedule,
          text: 'Đang chờ',
          description: 'Đang chờ xác nhận từ cửa hàng',
        );
      case 'accepted':
        return StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          text: 'Đã xác nhận',
          description: 'Đơn đặt lịch đã được xác nhận',
        );
      case 'canceled':
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          text: 'Đã hủy',
          description: 'Đơn đặt lịch đã bị hủy',
        );
      case 'ended':
        return StatusInfo(
          color: Colors.blue,
          icon: Icons.check_circle,
          text: 'Hoàn thành',
          description: 'Dịch vụ đã hoàn thành',
        );
      case 'overtime':
        return StatusInfo(
          color: AppColor.violetColor,
          icon: Icons.access_time,
          text: 'Quá giờ',
          description: 'Dịch vụ đã quá giờ',
        );

      default:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.info,
          text: status,
          description: 'Trạng thái: $status',
        );
    }
  }

  // Action Methods
  Future<void> _showCancelConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Không',
              style: AppTextStyle(context).bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Có, hủy đặt lịch',
              style: AppTextStyle(context).bodyText.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelBooking();
    }
  }

  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);

    try {
      await ref.read(storeController.notifier).cancelBooking(_booking!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đặt lịch thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
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

  void _shareBookingDetails() {
    final bookingInfo = '''
🐾 Đặt lịch tại ${_booking?.storeName}
📅 ${_formatDateTime(_booking!.startTime)}
🏷️ ${_booking?.serviceName}
🐕 ${_booking?.petName}
💰 ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_booking?.cost)}
📍 ${_booking?.address}
''';

    Share.share(bookingInfo, subject: 'Chi tiết đặt lịch #${_booking?.id}');
  }

  void _openMap() {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_booking!.address)}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _contactStore() {
    // Implement phone call functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Liên hệ cửa hàng',
              style: AppTextStyle(context).title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Gap(16.h),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColor.violetColor.withOpacity(0.1),
                child: Icon(Icons.phone, color: AppColor.violetColor),
              ),
              title: Text('Gọi điện thoại'),
              subtitle: Text('Liên hệ trực tiếp với cửa hàng'),
              onTap: () {
                Navigator.pop(context);
                // launchUrl(Uri.parse('tel:${widget.booking.}'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openChat() {
    // Implement chat functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Nhắn tin với cửa hàng',
              style: AppTextStyle(context).title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Gap(16.h),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColor.violetColor.withOpacity(0.1),
                child: Icon(Icons.message, color: AppColor.violetColor),
              ),
              title: Text('Mở chat'),
              subtitle: Text('Trò chuyện với cửa hàng'),
              // onTap: () {
              //   Navigator.pop(context);
              //   // Navigate to chat screen
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ChatScreen(
              //         storeId: widget.booking.storeId,
              //         storeName: widget.booking.storeName,
              //       ),
              //     ),
              //   );
              // },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle(context).bodyText.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Status Card Shimmer
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Gap(8.h),
                            Container(
                              width: 200.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Card Shimmer
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(16.h),
                  ...List.generate(
                      3,
                      (index) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Gap(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                      ),
                                      Gap(4.h),
                                      Container(
                                        width: 150.w,
                                        height: 14.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),

            // Service Details Card Shimmer
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(16.h),
                  ...List.generate(
                      4,
                      (index) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 100.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                Container(
                                  width: 120.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),

            // Payment Card Shimmer
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Container(
                        width: 100.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Location Card Shimmer
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(16.h),
                  Container(
                    width: double.infinity,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}

// Helper Classes
class StatusInfo {
  final Color color;
  final IconData icon;
  final String text;
  final String description;

  StatusInfo({
    required this.color,
    required this.icon,
    required this.text,
    required this.description,
  });
}

import 'package:fluffypawuser/models/booking/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' show sin;

class BookingHistoryLayout extends ConsumerStatefulWidget {
  final bool hasNewBooking;

  const BookingHistoryLayout({
    Key? key,
    this.hasNewBooking = false,
  }) : super(key: key);

  @override
  ConsumerState<BookingHistoryLayout> createState() =>
      _BookingHistoryLayoutState();
}

class _BookingHistoryLayoutState extends ConsumerState<BookingHistoryLayout>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showNewBookingMessage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
      if (widget.hasNewBooking) {
        setState(() => _showNewBookingMessage = true);
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(storeController.notifier).getAllBookings();
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
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0) ...[
                Container(
                  width: 100.w,
                  height: 24.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 200.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                    ),
                                    Gap(8.h),
                                    Container(
                                      width: 150.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Row(
                            children: [
                              Container(
                                width: 16.w,
                                height: 16.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Gap(8.w),
                              Expanded(
                                child: Container(
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Row(
                            children: [
                              Container(
                                width: 16.w,
                                height: 16.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Gap(8.w),
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
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                      ),
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
                            width: 80.w,
                            height: 20.h,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewBookingMessage() {
    if (!_showNewBookingMessage) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Shimmer.fromColors(
              baseColor: Colors.blue.shade100.withOpacity(0.3),
              highlightColor: Colors.blue.shade50.withOpacity(0.1),
              period: const Duration(seconds: 3),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.violetColor.withOpacity(0.8),
                    AppColor.violetColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.violetColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.violetColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.celebration,
                            color: AppColor.violetColor,
                            size: 24.sp,
                          ),
                        ),
                      );
                    },
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.white.withOpacity(0.7),
                      period: const Duration(seconds: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hooray!',
                                style: AppTextStyle(context).title.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              Gap(4.w),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1500),
                                tween: Tween(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset:
                                        Offset(0, sin(value * 2 * 3.14159) * 4),
                                    child: Text(
                                      '🎉',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Gap(4.h),
                          Text(
                            'Bạn vừa hoàn thành đặt chỗ mới',
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _showNewBookingMessage = false);
                        _animationController.stop();
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                          size: 20.sp,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(storeController.notifier).bookings ?? [];
    final isControllerLoading = ref.watch(storeController);

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
              ? AppColor.blackColor
              : AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Lịch sử đặt lịch',
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
          RefreshIndicator(
            onRefresh: _loadBookings,
            color: AppColor.violetColor,
            child: _isLoading || isControllerLoading
                ? _buildShimmerLoading()
                : _buildBookingList(bookings),
          ),
          _buildNewBookingMessage(),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            Gap(16.h),
            Text(
              'Chưa có lịch đặt nào',
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    // Group bookings by date
    final Map<String, List<BookingModel>> groupedBookings = {};
    final now = DateTime.now();

    // Sort bookings by date (newest first)
    bookings.sort((a, b) => b.createDate.compareTo(a.createDate));

    // Get the newest booking's ID for highlighting
    final newestBookingId = bookings.first.id;

    for (var booking in bookings) {
      final bookingDate = booking.createDate;
      final difference = now.difference(bookingDate).inDays;

      String groupKey;
      if (difference == 0) {
        groupKey = 'Hôm nay';
      } else if (difference == 1) {
        groupKey = 'Hôm qua';
      } else if (difference < 7) {
        groupKey = DateFormat('EEEE', 'vi_VN').format(bookingDate);
      } else {
        groupKey = 'Cũ hơn';
      }

      if (!groupedBookings.containsKey(groupKey)) {
        groupedBookings[groupKey] = [];
      }
      groupedBookings[groupKey]!.add(booking);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: groupedBookings.length,
      itemBuilder: (context, index) {
        final groupKey = groupedBookings.keys.elementAt(index);
        final groupBookings = groupedBookings[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, top: index == 0 ? 0 : 16.h),
              child: Text(
                groupKey,
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...groupBookings.map((booking) => _buildBookingCard(
                  booking,
                  isNew: booking.id == newestBookingId && widget.hasNewBooking,
                )),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, {bool isNew = false}) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (booking.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hoàn thành';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      case 'pending':
        statusColor = AppColor.violetColor;
        statusIcon = Icons.schedule;
        statusText = 'Đang chờ';
        break;
      default:
        statusColor = AppColor.violetColor;
        statusIcon = Icons.info;
        statusText = booking.status;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: isNew
            ? Border.all(color: AppColor.violetColor.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isNew
                ? AppColor.violetColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: isNew ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.storeName,
                            style: AppTextStyle(context).subTitle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(4.h),
                          Text(
                            booking.serviceName,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16.sp,
                            color: statusColor,
                          ),
                          Gap(4.w),
                          Text(
                            statusText,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    Gap(4.w),
                    Expanded(
                      child: Text(
                        booking.address,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Gap(8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    Gap(4.w),
                    Text(
                      DateFormat('HH:mm, dd/MM/yyyy').format(booking.startTime),
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: AppTextStyle(context).bodyText.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(booking.cost)}đ',
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
}

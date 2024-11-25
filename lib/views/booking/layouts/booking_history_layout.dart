import 'dart:math';

import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_model.dart';
import 'package:fluffypawuser/views/booking/layouts/booking_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isRating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showNewBookingMessage = false;
  String _selectedStatus = 'all';
  int? _viewedBookingId;

  final _statusFilters = AppColor.bookingStatusFilters;
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

    // Thêm dòng này để load data khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings(); // Load booking history data
      _checkNewBooking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(storeController.notifier).bookings ?? [];
    final isControllerLoading = ref.watch(storeController);

    final filteredBookings = _selectedStatus == 'all'
        ? bookings
        : bookings
            .where((b) => b.status.toLowerCase() == _selectedStatus)
            .toList();

    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
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
      body: AnimationLimiter(
        child: Stack(
          children: [
            Column(
              children: [
                _buildStatusFilters(),
                Expanded(
                  child: RefreshIndicator(
                    displacement: 20.h,
                    strokeWidth: 3,
                    color: AppColor.violetColor,
                    backgroundColor: Colors.white,
                    onRefresh: _loadBookings,
                    child: _isLoading || isControllerLoading
                        ? _buildShimmerLoading()
                        : _buildBookingList(filteredBookings),
                  ),
                ),
              ],
            ),
            _buildNewBookingMessage(),
          ],
        ),
      ),
    );
  }
  Future<void> _checkNewBooking() async {
    if (widget.hasNewBooking && mounted) {
      final bookings = ref.read(storeController.notifier).bookings ?? [];
      if (bookings.isNotEmpty) {
        final newestBooking = bookings.first;
        final hasViewed = await ref.read(hiveStoreService).hasViewedBooking(newestBooking.id);
        
        if (!hasViewed) {
          setState(() {
            _showNewBookingMessage = true;
            _viewedBookingId = newestBooking.id;
          });
          _animationController.repeat(reverse: true);
        }
      }
    }
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

  Widget _buildStatusFilters() {
    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _selectedStatus == filter['id'];
          final color = filter['color'] as Color;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedStatus = filter['id']);
                        HapticFeedback.lightImpact();
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              filter['icon'],
                              size: 18.sp,
                              color: isSelected ? Colors.white : color,
                            ),
                            Gap(6.w),
                            Text(
                              filter['label'],
                              style: AppTextStyle(context)
                                  .bodyTextSmall
                                  .copyWith(
                                    color: isSelected ? Colors.white : color,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: Duration(seconds: 1),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.history,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
            Gap(16.h),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOut,
              )),
              child: Text(
                'Chưa có lịch đặt nào',
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final Map<String, List<BookingModel>> groupedBookings = {};
    final now = DateTime.now();
    List<BookingModel> sortedBookings = List.from(bookings)
      ..sort((a, b) => b.createDate.compareTo(a.createDate));
    final newestBookingId = sortedBookings.first.id;

    for (var booking in sortedBookings) {
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

      groupedBookings.putIfAbsent(groupKey, () => []);
      groupedBookings[groupKey]!.add(booking);
    }

    final sortedGroupKeys = groupedBookings.keys.toList()
      ..sort((a, b) {
        final order = {
          'Hôm nay': 0,
          'Hôm qua': 1,
          'Cũ hơn': 999,
        };
        return (order[a] ?? 2).compareTo(order[b] ?? 2);
      });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: sortedGroupKeys.length,
      itemBuilder: (context, index) {
        final groupKey = sortedGroupKeys[index];
        final groupBookings = groupedBookings[groupKey]!
          ..sort((a, b) => b.createDate.compareTo(a.createDate));

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 8.h, top: index == 0 ? 0 : 16.h),
                    child: Text(
                      groupKey,
                      style: AppTextStyle(context).title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...groupBookings.map((booking) => _buildBookingCard(
                        booking,
                        isNew: booking.id == newestBookingId &&
                            widget.hasNewBooking,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, {bool isNew = false}) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    final statusText = _getStatusText(booking.status);
    final statusBgColor = AppColor.getStatusBgColor(booking.status);
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          // Đánh dấu đã xem booking khi nhấn vào
          if (isNew) {
            await ref.read(hiveStoreService).markBookingAsViewed(booking.id);
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailLayout(booking: booking),
            ),
          ).then((_) {
            // Khi quay lại, kiểm tra và ẩn thông báo nếu cần
            if (mounted && _viewedBookingId == booking.id) {
              setState(() {
                _showNewBookingMessage = false;
              });
              _animationController.stop();
            }
          });
        },
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: isNew
                ? Border.all(color: statusColor.withOpacity(0.5), width: 2)
                : Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: isNew
                    ? statusColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: isNew ? 15 : 8,
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
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: statusColor.withOpacity(0.2),
                                width: 1,
                              ),
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
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
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
                          DateFormat('HH:mm, dd/MM/yyyy')
                              .format(booking.startTime),
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Ink(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                      ),
                      Row(
                        children: [
                          if (booking.status.toLowerCase() == 'ended')
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => _showRatingDialog(booking),
                                icon: Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 24.sp,
                                ),
                                tooltip: 'Đánh giá dịch vụ',
                              ),
                            ),
                          Text(
                            '${NumberFormat('#,###', 'vi_VN').format(booking.cost)}đ',
                            style: AppTextStyle(context).title.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColor.bookingPending;
      case 'accepted':
        return AppColor.bookingAccepted;
      case 'overtime':
        return AppColor.bookingOvertime;
      case 'ended':
        return AppColor.bookingEnded;
      case 'canceled':
        return AppColor.bookingCanceled;
      default:
        return AppColor.greyColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'overtime':
        return Icons.timer_off_outlined;
      case 'ended':
        return Icons.task_alt;
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'accepted':
        return 'Đã xác nhận';
      case 'overtime':
        return 'Quá giờ';
      case 'ended':
        return 'Đã kết thúc';
      case 'canceled':
        return 'Đã hủy';
      default:
        return status;
    }
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
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                Gap(8.w),
                Expanded(child: Text('Có lỗi xảy ra: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColor.redColor,
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

  void _showRatingDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 48.sp,
              ),
            ),
            Gap(16.h),
            Text(
              'Đánh giá dịch vụ',
              style: AppTextStyle(context).title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Gap(8.h),
            Text(
              'Bạn đánh giá như thế nào về dịch vụ của ${booking.storeName}?',
              textAlign: TextAlign.center,
              style: AppTextStyle(context).bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Gap(20.h),
            _isRating
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    strokeWidth: 3,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 200 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                child: IconButton(
                                  onPressed: () => _handleRating(index + 1),
                                  icon: Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 36.sp,
                                  ),
                                  hoverColor: Colors.amber.withOpacity(0.1),
                                  splashColor: Colors.amber.withOpacity(0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            Gap(16.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Để sau',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRating(int rating) async {
    setState(() => _isRating = true);
    try {
      // TODO: Implement rating API call here
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              Gap(8.w),
              Text('Cảm ơn bạn đã đánh giá!'),
            ],
          ),
          backgroundColor: AppColor.lime500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              Gap(8.w),
              Expanded(child: Text('Có lỗi xảy ra: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppColor.redColor,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } finally {
      setState(() => _isRating = false);
    }
  }
}

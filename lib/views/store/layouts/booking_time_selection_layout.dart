import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/views/store/layouts/select_pet_for_hotel_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingTimeSelectionLayout extends ConsumerStatefulWidget {
  final int storeServiceId;
  final double price;
  final int storeId;

  const BookingTimeSelectionLayout({
    Key? key,
    required this.storeServiceId,
    required this.price,
    required this.storeId
  }) : super(key: key);

  @override
  ConsumerState<BookingTimeSelectionLayout> createState() =>
      _BookingTimeSelectionLayoutState();
}

class _BookingTimeSelectionLayoutState
    extends ConsumerState<BookingTimeSelectionLayout> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime? _displayCheckInDate;
  DateTime? _displayCheckOutDate;
  DateTime _focusedDay = DateTime.now();
  List<ServiceTimeModel> _selectedTimeSlots = [];
  List<DateTime> _daysWithoutSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTimeSlots());
  }

  Future<void> _loadTimeSlots() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);
      await ref
          .read(storeController.notifier)
          .getServiceTimeWithStoreId(widget.storeServiceId, widget.storeId);
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Cập nhật lại selected slots nếu đã chọn khoảng thời gian
      if (_checkInDate != null && _checkOutDate != null) {
        _updateSelectedTimeSlots(
            ref.read(storeController.notifier).serviceTime ?? []);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading time slots: $e')),
      );
    }
  }

  bool _hasAvailableSlots(DateTime date, List<ServiceTimeModel> allTimeSlots) {
    return allTimeSlots
        .where((slot) => DateUtils.isSameDay(slot.startTime, date))
        .where((slot) => slot.currentPetOwner < slot.limitPetOwner)
        .isNotEmpty;
  }

  ServiceTimeModel? _getFirstAvailableTimeSlot(
      DateTime date, List<ServiceTimeModel> allTimeSlots) {
    final daySlots = allTimeSlots
        .where((slot) => DateUtils.isSameDay(slot.startTime, date))
        .where((slot) => slot.currentPetOwner < slot.limitPetOwner)
        .toList();

    daySlots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return daySlots.isNotEmpty ? daySlots.first : null;
  }

  void _updateSelectedTimeSlots(List<ServiceTimeModel> allTimeSlots) {
    if (_checkInDate == null) return;

    // Sử dụng checkOutDate nếu có, nếu không thì dùng checkInDate (cho lưu trú 1 ngày)
    final effectiveCheckOutDate = _checkOutDate ?? _checkInDate;

    // Tìm ngày check-in có thể book gần nhất
    _displayCheckInDate =
        _findNearestAvailableDate(_checkInDate!, allTimeSlots, true);

    // Tìm ngày check-out có thể book gần nhất (với lưu trú 1 ngày, sẽ là cùng ngày với check-in)
    _displayCheckOutDate =
        _checkOutDate != null
            ? _findNearestAvailableDate(_checkOutDate!, allTimeSlots, false)
            : _displayCheckInDate;

    final selectedSlots = <ServiceTimeModel>[];
    final unavailableDays = <DateTime>[];

    // Sử dụng ngày hiển thị để tính các slots
    if (_displayCheckInDate != null) {
      var currentDate = _displayCheckInDate!;
      final endDate = _checkOutDate ?? _displayCheckInDate!;

      // Điều chỉnh logic để xử lý cả trường hợp một ngày
      do {
        if (_hasAvailableSlots(currentDate, allTimeSlots)) {
          final slot = _getFirstAvailableTimeSlot(currentDate, allTimeSlots);
          if (slot != null) {
            selectedSlots.add(slot);
          }
        } else {
          unavailableDays.add(currentDate);
        }
        
        if (DateUtils.isSameDay(currentDate, endDate)) break;
        currentDate = currentDate.add(Duration(days: 1));
      } while (!currentDate.isAfter(endDate));
    }

    setState(() {
      _selectedTimeSlots = selectedSlots;
      _daysWithoutSlots = unavailableDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableTimeSlots =
        ref.watch(storeController.notifier).serviceTime ?? [];

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chọn thời gian',
          style: AppTextStyle(context).title,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                children: [
                  _buildCalendar(),
                  Gap(16.h),
                  if (_daysWithoutSlots.isNotEmpty) _buildWarningMessage(),
                  if (_daysWithoutSlots.isNotEmpty) Gap(16.h),
                  _buildSelectedDateRange(),
                  if (_selectedTimeSlots.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildSelectedTimeSlots(),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCalendar() {
    final availableTimeSlots =
        ref.watch(storeController.notifier).serviceTime ?? [];

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 30)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          if (_checkInDate == null) return false;
          if (_checkOutDate == null) return isSameDay(_checkInDate!, day);
          return (day.isAfter(_checkInDate!.subtract(Duration(days: 1))) &&
              day.isBefore(_checkOutDate!.add(Duration(days: 1))));
        },
        rangeStartDay: _checkInDate,
        rangeEndDay: _checkOutDate ?? _checkInDate,
        rangeSelectionMode: RangeSelectionMode.enforced,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        enabledDayPredicate: (day) {
          return !_shouldDisableDate(day, availableTimeSlots);
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleTextStyle: AppTextStyle(context).subTitle,
          leftChevronIcon:
              Icon(Icons.chevron_left, color: AppColor.violetColor),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: AppColor.violetColor),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColor.violetColor,
            shape: BoxShape.circle,
          ),
          rangeHighlightColor: AppColor.violetColor.withOpacity(0.2),
          withinRangeTextStyle: TextStyle(color: AppColor.blackColor),
          rangeStartDecoration: BoxDecoration(
            color: AppColor.violetColor,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: AppColor.violetColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColor.violetColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          disabledTextStyle: TextStyle(
            color: Colors.grey[400],
            decoration: TextDecoration.lineThrough,
          ),
          outsideTextStyle: TextStyle(color: Colors.grey[400]),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_daysWithoutSlots.any((d) => DateUtils.isSameDay(d, date))) {
              return Positioned(
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  width: 4.w,
                  height: 4.w,
                ),
              );
            }
            return null;
          },
        ),
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _checkInDate = start;
            _checkOutDate = end;
            _focusedDay = focusedDay;
            // Nếu chỉ chọn một ngày, cập nhật ngay
            if (start != null) {
              _updateSelectedTimeSlots(availableTimeSlots);
            }
          });
        },
      ),
    );
  }

  Widget _buildWarningMessage() {
    if (_daysWithoutSlots.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 24.sp,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lưu ý',
                      style: AppTextStyle(context).subTitle.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Gap(4.h),
                    Text(
                      'Một số ngày không có khung giờ trống',
                      style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.orange.shade800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Các ngày không có lịch:',
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                ),
                Gap(8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _daysWithoutSlots.map((date) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateRange() {
    if (_checkInDate == null) return SizedBox();

    final isOneDayStay = _checkOutDate == null || DateUtils.isSameDay(_checkInDate, _checkOutDate);
    final effectiveCheckOutDate = isOneDayStay 
        ? _checkInDate!.add(Duration(days: 1))
        : _checkOutDate!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.login, color: AppColor.violetColor, size: 20.sp),
              Gap(8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(_checkInDate!),
                      style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w600,
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
              Icon(Icons.logout, color: AppColor.violetColor, size: 20.sp),
              Gap(8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-out',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(effectiveCheckOutDate),
                      style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isOneDayStay)
                      Text(
                        '(Lưu trú 1 đêm)',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.orange,
                          fontSize: 12.sp,
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

  Widget _buildSelectedTimeSlots() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColor.violetColor,
                  size: 20.sp,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch trình booking của bạn',
                      style: AppTextStyle(context).subTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${_selectedTimeSlots.length} ngày đã được chọn',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _selectedTimeSlots.length + 1, // +1 for checkout day
            separatorBuilder: (context, index) => Divider(
              height: 24.h,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              // Xử lý ngày check-out (ngày cuối cùng)
              if (index == _selectedTimeSlots.length) {
                final checkoutDate =
                    _selectedTimeSlots.last.startTime.add(Duration(days: 1));
                return Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('dd').format(checkoutDate),
                          style: AppTextStyle(context).subTitle.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                                .format(checkoutDate),
                            style: AppTextStyle(context).bodyText.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Gap(4.h),
                          Text(
                            'Check-out lúc ${DateFormat('HH:mm').format(checkoutDate)}',
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.orange,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Xử lý các ngày trong khoảng booking
              final slot = _selectedTimeSlots[index];
              final isCheckInDay = index == 0;

              return Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColor.violetColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('dd').format(slot.startTime),
                        style: AppTextStyle(context).subTitle.copyWith(
                              color: AppColor.violetColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                              .format(slot.startTime),
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (isCheckInDay) ...[
                          Gap(4.h),
                          Text(
                            'Check-in lúc ${DateFormat('HH:mm').format(slot.startTime)}',
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: AppColor.violetColor,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  DateTime? _findNearestAvailableDate(
      DateTime date, List<ServiceTimeModel> allTimeSlots, bool searchForward) {
    var searchDate = date;
    final endDate = DateTime.now().add(Duration(days: 30));

    while (searchForward
        ? searchDate.isBefore(endDate)
        : searchDate.isAfter(DateTime.now())) {
      if (_hasAvailableSlots(searchDate, allTimeSlots)) {
        return searchDate;
      }
      searchDate = searchForward
          ? searchDate.add(Duration(days: 1))
          : searchDate.subtract(Duration(days: 1));
    }
    return null;
  }

  Widget _buildBottomBar() {
    // Sửa lại logic kiểm tra điều kiện để kích hoạt nút
    final hasValidSlots = _selectedTimeSlots.isNotEmpty;
    final hasValidDates = _checkInDate != null; // Chỉ cần kiểm tra checkInDate
    final hasValidSelection = hasValidDates && hasValidSlots;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedTimeSlots.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thời gian lưu trú:',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          // Điều chỉnh hiển thị số đêm lưu trú
                          '${_selectedTimeSlots.length} đêm',
                          style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColor.violetColor,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h, color: Colors.grey[200]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Check-in:',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(_selectedTimeSlots.first.startTime),
                          style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Check-out:',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                            _selectedTimeSlots.last.startTime.add(Duration(days: 1)),
                          ),
                          style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h, color: Colors.grey[200]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(_selectedTimeSlots.length * widget.price),
                          style: AppTextStyle(context).subTitle.copyWith(
                            color: AppColor.violetColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: hasValidSelection
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectPetForHotelLayout(
                            timeSlots: _selectedTimeSlots,
                            storeServiceId: widget.storeServiceId,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size(double.infinity, 52.h),
                disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
              ),
              child: Text(
                'Tiếp tục',
                style: AppTextStyle(context).buttonText.copyWith(
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldDisableDate(DateTime day, List<ServiceTimeModel> allTimeSlots) {
    return !_hasAvailableSlots(day, allTimeSlots);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateSelectionScreen extends StatefulWidget {
  final DateTime initialCheckIn;
  final DateTime initialCheckOut;

  const DateSelectionScreen({
    Key? key,
    required this.initialCheckIn,
    required this.initialCheckOut,
  }) : super(key: key);

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  late DateTime selectedCheckIn;
  late DateTime selectedCheckOut;
  late List<DateTime> displayedMonths;
  int nights = 0;
  DateTime? firstSelectedDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN');
    selectedCheckIn = widget.initialCheckIn;
    selectedCheckOut = widget.initialCheckOut;
    _initDisplayedMonths();
    _calculateNights();
  }

  void _initDisplayedMonths() {
    final now = DateTime.now();
    displayedMonths = List.generate(3, (index) {
      return DateTime(now.year, now.month + index);
    });
  }

  void _calculateNights() {
    nights = selectedCheckOut.difference(selectedCheckIn).inDays;
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      if (firstSelectedDate == null) {
        // Đây là lần chọn đầu tiên
        firstSelectedDate = date;
        selectedCheckIn = date;
        selectedCheckOut = date;
      } else {
        // Đây là lần chọn thứ hai
        if (date.isBefore(firstSelectedDate!)) {
          // Nếu ngày được chọn trước ngày đầu tiên
          selectedCheckIn = date;
          selectedCheckOut = firstSelectedDate!;
        } else {
          // Nếu ngày được chọn sau ngày đầu tiên
          selectedCheckIn = firstSelectedDate!;
          selectedCheckOut = date;
        }
        // Reset firstSelectedDate để cho phép chọn lại từ đầu
        firstSelectedDate = null;
      }
      _calculateNights();
    });
  }


  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  Widget _buildMonthCalendars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayedMonths.map((month) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Tháng ${DateFormat('MM/yyyy').format(month)}',
                style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildCalendarForMonth(month),
            SizedBox(height: 24.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCalendarForMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;
    final today = DateTime.now();
    final List<Widget> dayWidgets = [];

    // Add weekday headers
    for (int i = 1; i <= 7; i++) {
      dayWidgets.add(
        Container(
          width: 40.w,
          alignment: Alignment.center,
          child: Text(
            _getWeekdayName(i),
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    // Add empty spaces for days before the first day of month
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(Container(width: 40.w));
    }

    // Add day numbers
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(month.year, month.month, i);
      final isSelectable = date.isAfter(today.subtract(const Duration(days: 1)));
      final isSelected = DateUtils.isSameDay(date, selectedCheckIn) ||
                        DateUtils.isSameDay(date, selectedCheckOut);
      final isInRange = date.isAfter(selectedCheckIn) && 
                       date.isBefore(selectedCheckOut);

      dayWidgets.add(
        GestureDetector(
          onTap: isSelectable ? () => _handleDateSelection(date) : null,
          child: Container(
            width: 40.w,
            height: 40.w,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.violetColor :
                     isInRange ?  AppColor.violetColor.withOpacity(0.1) :
                     Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                i.toString(),
                style: AppTextStyle(context).bodyText.copyWith(
                  color: isSelected ? Colors.white :
                         !isSelectable ? Colors.grey :
                         isInRange ? const Color(0xFF4B8364) :
                         Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 4.w,
      runSpacing: 4.h,
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.violetColor,
        elevation: 0,
        title: Text(
          'Chọn lịch',
          style: AppTextStyle(context).title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header with selected dates
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            color: AppColor.violetColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày nhận',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedCheckIn),
                          style: AppTextStyle(context).title.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Ngày trả',
                          style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedCheckOut),
                          style: AppTextStyle(context).title.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildMonthCalendars(),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  '$nights Đêm',
                  style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: nights > 0 ? () {
                    Navigator.pop(context, {
                      'checkIn': selectedCheckIn,
                      'checkOut': selectedCheckOut,
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.violetColor,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Xác nhận',
                    style: AppTextStyle(context).buttonText,
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
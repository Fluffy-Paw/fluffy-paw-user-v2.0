import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/views/booking/booking_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BookingConfirmationSheet extends ConsumerStatefulWidget {
  final List<ServiceTimeModel> timeSlots;
  final PetModel pet;
  final int storeServiceId;

  const BookingConfirmationSheet({
    Key? key,
    required this.timeSlots,
    required this.pet,
    required this.storeServiceId,
  }) : super(key: key);

  @override
  ConsumerState<BookingConfirmationSheet> createState() =>
      _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState
    extends ConsumerState<BookingConfirmationSheet> {
  final _descriptionController = TextEditingController();
  String _selectedPayment = 'COD'; // Default payment method
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
  setState(() => _isLoading = true);

  try {
    final List<int> storeServiceIds = widget.timeSlots.map((slot) => slot.id).toList();
    
    final result = await ref.read(storeController.notifier).selectBookingTime(
      widget.pet.id,
      storeServiceIds,
      _selectedPayment,
      _descriptionController.text,
    );

    if (!mounted) return;

    final statusCode = result['statusCode'];
    final message = result['message'];
    
    if (statusCode == 200) {
      // Set state providers
      ref.read(hasNewBookingProvider.notifier).state = true;
      ref.read(selectedIndexProvider.notifier).state = 1;
      
      // Đóng bottom sheet và show success dialog
      Navigator.pop(context);
      _showSuccessDialog();
    } else {
      _showErrorSnackBar(message ?? 'Đã có lỗi xảy ra trong quá trình đặt phòng');
    }
  } catch (e) {
    if (!mounted) return;
    print('Booking error: $e');
    _showErrorSnackBar('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48.sp,
                ),
              ),
              Gap(16.h),
              Text(
                'Đặt phòng thành công!',
                style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(8.h),
              Text(
                'Thông tin đặt phòng:',
                style: AppTextStyle(context).subTitle,
              ),
              Gap(8.h),
              _buildSuccessInfo(
                'Thời gian lưu trú: ${widget.timeSlots.length} đêm',
                Icons.calendar_today,
              ),
              _buildSuccessInfo(
                'Check-in: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.timeSlots.first.startTime)}',
                Icons.login,
              ),
              _buildSuccessInfo(
                'Check-out: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.timeSlots.last.startTime.add(Duration(days: 1)))}',
                Icons.logout,
              ),
              Gap(24.h),
              // Tự động chuyển sau 2 giây
              FutureBuilder(
                future: Future.delayed(Duration(seconds: 2)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Navigate và clear stack
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.core,
                        (route) => false,
                      );
                    });
                  }
                  return Text(
                    'Đang chuyển đến trang đơn đặt...',
                    textAlign: TextAlign.center,
                    style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSuccessInfo(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColor.violetColor),
          Gap(8.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle(context).bodyText,
            ),
          ),
        ],
      ),
    );
  }
// Future<void> _showConfirmationDialog() async {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => BookingConfirmationSheet(
//       timeSlots: widget.timeSlots,
//       pet: _selectedPet!,
//       storeServiceId: widget.storeServiceId,
//     ),
//   );
// }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBookingDetails(),
            _buildPaymentSelection(),
            _buildDescriptionField(),
            _buildConfirmButton(),
            Gap(MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Xác nhận đặt phòng',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                splashRadius: 24.r,
              ),
            ],
          ),
          Divider(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết đặt phòng',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(12.h),
          _buildDetailItem(
            icon: Icons.pets,
            title: 'Thú cưng',
            value: widget.pet.name,
          ),
          _buildDetailItem(
            icon: Icons.calendar_today,
            title: 'Thời gian lưu trú',
            value: '${widget.timeSlots.length} đêm',
          ),
          _buildDetailItem(
            icon: Icons.login,
            title: 'Check-in',
            value: DateFormat('dd/MM/yyyy HH:mm')
                .format(widget.timeSlots.first.startTime),
          ),
          _buildDetailItem(
            icon: Icons.logout,
            title: 'Check-out',
            value: DateFormat('dd/MM/yyyy HH:mm')
                .format(widget.timeSlots.last.startTime.add(Duration(days: 1))),
          ),
          Divider(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColor.violetColor, size: 20.sp),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phương thức thanh toán',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(12.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildPaymentOption(
                  title: 'Tiền mặt',
                  value: 'COD',
                  icon: Icons.money,
                ),
                Divider(height: 1),
                _buildPaymentOption(
                  title: 'Ví Fluffy Pay',
                  value: 'FluffyPay',
                  icon: Icons.account_balance,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPayment,
      onChanged: (value) => setState(() => _selectedPayment = value!),
      title: Row(
        children: [
          Icon(icon, size: 20.sp),
          Gap(8.w),
          Text(
            title,
            style: AppTextStyle(context).bodyText,
          ),
        ],
      ),
      activeColor: AppColor.violetColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi chú',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(12.h),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú cho nhân viên (không bắt buộc)',
              hintStyle: AppTextStyle(context).bodyText.copyWith(
                    color: Colors.grey,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColor.violetColor),
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.violetColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          minimumSize: Size(double.infinity, 48.h),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                  strokeWidth: 2.w,
                ),
              )
            : Text(
                'Xác nhận đặt phòng',
                style: AppTextStyle(context).buttonText,
              ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BookingConfirmationLayout extends ConsumerStatefulWidget {
  // final List<int> selectedPetIds;
  // final int timeSlotId;
  // final int storeServiceId;
  // final int storeId;
  final BookingDataModel bookingData;
  final List<int> selectedPetIds;

  const BookingConfirmationLayout({
    super.key,
    required this.bookingData,
    required this.selectedPetIds,
  });

  @override
  ConsumerState<BookingConfirmationLayout> createState() =>
      _BookingConfirmationLayoutState();
}

class _BookingConfirmationLayoutState
    extends ConsumerState<BookingConfirmationLayout> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedPaymentMethod = 'COD';
  List<PetModel> selectedPets = [];
  ServiceTimeModel? timeSlot;
  StoreServiceModel? service;
  StoreModel? store;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu từ bookingData
    setState(() {
      service = widget.bookingData.service;
      timeSlot = widget.bookingData.timeSlot;
      store = widget.bookingData.store;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPetData();
    });
  }

  Future<void> _loadPetData() async {
    await ref.read(petController.notifier).getPetList();
    if (mounted) {
      setState(() {
        selectedPets = ref
                .read(hiveStoreService)
                .getPetInfo()
                ?.where((pet) => widget.selectedPetIds.contains(pet.id))
                .toList() ??
            [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Xác nhận đặt lịch',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Thông tin dịch vụ',
                      child: _buildServiceInfo(),
                    ),
                    Gap(16.h),
                    _buildSection(
                      title: 'Chi nhánh',
                      child: _buildStoreInfo(),
                    ),
                    Gap(16.h),
                    _buildSection(
                      title: 'Thú cưng được chọn',
                      child: _buildPetsList(),
                    ),
                    Gap(16.h),
                    _buildSection(
                      title: 'Thời gian',
                      child: _buildTimeInfo(),
                    ),
                    Gap(16.h),
                    _buildSection(
                      title: 'Phương thức thanh toán',
                      child: _buildPaymentMethods(),
                    ),
                    Gap(16.h),
                    _buildSection(
                      title: 'Ghi chú',
                      child: _buildDescriptionInput(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle(context).title.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(12.h),
        child,
      ],
    );
  }

  Widget _buildServiceInfo() {
    if (service == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service!.name,
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(8.h),
          Text(
            service!.description ?? 'Không có mô tả',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giá dịch vụ',
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                  Text(
                    '${NumberFormat('#,###', 'vi_VN').format(service!.cost)}đ',
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: AppColor.violetColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Thời gian dự kiến',
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                  Text(
                    '${service!.duration} phút',
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
  return Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi nhánh',
          style: AppTextStyle(context).subTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Gap(8.h),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                // Thay đổi từ store?.logo thành store?.files.first.file
                imageUrl: store?.files.isNotEmpty == true 
                    ? store!.files.first.file 
                    : '',
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.violetColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.store_rounded,
                    size: 30.sp,
                    color: Colors.grey[400],
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
                    store?.name ?? 'Loading...',
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Gap(4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColor.violetColor,
                      ),
                      Gap(4.w),
                      Expanded(
                        child: Text(
                          store?.address ?? 'Loading...',
                          style: AppTextStyle(context).bodyTextSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16.sp,
                        color: AppColor.violetColor,
                      ),
                      Gap(4.w),
                      Text(
                        store?.phone ?? 'Loading...',
                        style: AppTextStyle(context).bodyTextSmall,
                      ),
                    ],
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

  Widget _buildPetsList() {
    return Column(
      children: selectedPets.map((pet) => _buildPetCard(pet)).toList(),
    );
  }

  Widget _buildPetCard(PetModel pet) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: pet.image ?? '',
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.pets, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.pets, color: Colors.grey),
              ),
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: AppTextStyle(context).subTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${pet.weight} kg',
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

  Widget _buildTimeInfo() {
    if (timeSlot == null) {
      return Center(child: CircularProgressIndicator());
    }

    final formatter = DateFormat('HH:mm dd/MM/yyyy');
    return Container(
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
      child: Text(
        formatter.format(timeSlot!.startTime),
        style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
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
          _buildPaymentOption(
            'COD',
            'Thanh toán khi đến cửa hàng',
            Icons.money,
          ),
          Divider(height: 24.h),
          _buildPaymentOption(
            'FluffyPay',
            'Thanh toán bằng FluffyPay',
            Icons.payment,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Row(
        children: [
          Radio(
            value: value,
            groupValue: selectedPaymentMethod,
            activeColor: AppColor.violetColor,
            onChanged: (value) =>
                setState(() => selectedPaymentMethod = value!),
          ),
          Gap(8.w),
          Icon(icon, color: AppColor.violetColor),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
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
      child: TextField(
        controller: descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Nhập ghi chú cho cửa hàng...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColor.violetColor),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    double totalCost = (service?.cost ?? 0).toDouble();
    totalCost *= selectedPets.length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền:',
                style: AppTextStyle(context).subTitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${NumberFormat('#,###', 'vi_VN').format(totalCost)}đ',
                style: AppTextStyle(context).title.copyWith(
                      color: AppColor.violetColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Gap(16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleBooking(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Xác nhận đặt lịch',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      // Attempt to create booking
      final result = await ref.read(storeController.notifier).createBooking(
            widget.bookingData.timeSlot.id,
            widget.selectedPetIds,
            selectedPaymentMethod,
            descriptionController.text,
          );

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      // Only navigate if booking was successful
      if (result['success']) {
        if (mounted) {
          ref.read(selectedIndexProvider.notifier).state = 1;
          ref.read(hasNewBookingProvider.notifier).state = true;

          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.core,
            (route) => false,
          );
        }
      }
    } catch (error) {
      // Hide loading indicator if still showing
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceAll('Exception: ', ''),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}

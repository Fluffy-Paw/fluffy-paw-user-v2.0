import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BookingConfirmationLayout extends ConsumerStatefulWidget {
  final List<int> selectedPetIds;
  final int timeSlotId;
  final int storeServiceId;

  const BookingConfirmationLayout({
    super.key,
    required this.selectedPetIds,
    required this.timeSlotId,
    required this.storeServiceId,
  });

  @override
  ConsumerState<BookingConfirmationLayout> createState() =>
      _BookingConfirmationLayoutState();
}

class _BookingConfirmationLayoutState
    extends ConsumerState<BookingConfirmationLayout> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedPaymentMethod = 'COD'; // Default payment method
  List<PetModel> selectedPets = [];
  ServiceTimeModel? timeSlot;
  StoreServiceModel? service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Load pet details
    await ref.read(petController.notifier).getPetList(); // Đợi getPetList hoàn thành
    if (mounted) {
      final allPets = ref.read(hiveStoreService).getPetInfo() ?? [];
      setState(() {
        selectedPets = allPets
            .where((pet) => widget.selectedPetIds.contains(pet.id))
            .toList();
      });
    }

    // Load time slot details
    await ref
        .read(storeController.notifier)
        .getServiceTime(widget.storeServiceId);
    if (mounted) {
      final allTimeSlots = ref.read(storeController.notifier).serviceTime ?? [];
      setState(() {
        timeSlot = allTimeSlots
            .firstWhere((slot) => slot.id == widget.timeSlotId);
      });
    }

    // Load service details
    if (mounted) {
      setState(() {
        service = ref
            .read(storeController.notifier)
            .storeServices
            ?.firstWhere((service) => service.id == widget.storeServiceId);
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
            'Giá: \$${service!.cost}',
            style: AppTextStyle(context).bodyText.copyWith(
              color: AppColor.violetColor,
              fontWeight: FontWeight.w600,
            ),
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
            'PayOS',
            'Thanh toán qua PayOS',
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
            onChanged: (value) => setState(() => selectedPaymentMethod = value!),
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
    // Convert service cost từ num sang double
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
            offset: Offset(0, -5),
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
                '\$${totalCost.toStringAsFixed(2)}',
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
              onPressed: () {
                // TODO: Handle booking confirmation
                final bookingData = {
                  'petIds': widget.selectedPetIds,
                  'timeSlotId': widget.timeSlotId,
                  'storeServiceId': widget.storeServiceId,
                  'paymentMethod': selectedPaymentMethod,
                  'description': descriptionController.text,
                  'totalCost': totalCost,
                };
                print('Booking data: $bookingData');
              },
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

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
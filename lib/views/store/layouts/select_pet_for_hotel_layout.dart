import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/views/store/layouts/booking_confirm_sheet_for_hotel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SelectPetForHotelLayout extends ConsumerStatefulWidget {
  final List<ServiceTimeModel> timeSlots;
  final int storeServiceId;

  const SelectPetForHotelLayout({
    Key? key,
    required this.timeSlots,
    required this.storeServiceId,
  }) : super(key: key);

  @override
  ConsumerState<SelectPetForHotelLayout> createState() =>
      _SelectPetForHotelLayoutState();
}

class _SelectPetForHotelLayoutState
    extends ConsumerState<SelectPetForHotelLayout> {
  PetModel? _selectedPet;
  List<PetModel> _pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPets());
  }

  Future<void> _loadPets() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Wrap trong Future để tránh modify provider trong build cycle
      await Future(() async {
        await ref.read(petController.notifier).getPetList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pets: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Di chuyển việc đọc pets ra khỏi initState
    final pets = ref.watch(petController.notifier).pets ?? [];

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chọn thú cưng',
          style: AppTextStyle(context).title,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTimeInfo(),
                Gap(16.h),
                _buildPetList(pets),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTimeInfo() {
    return Container(
      margin: EdgeInsets.all(16.w),
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
              Icon(Icons.calendar_today, color: AppColor.violetColor),
              Gap(12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian lưu trú',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  Text(
                    '${widget.timeSlots.length} đêm',
                    style: AppTextStyle(context).subTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.access_time, color: AppColor.violetColor),
              Gap(12.w),
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
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(widget.timeSlots.first.startTime),
                      style: AppTextStyle(context).subTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-out',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(
                        widget.timeSlots.last.startTime.add(Duration(days: 1))),
                    style: AppTextStyle(context).subTitle.copyWith(
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

  Widget _buildPetList(List<PetModel> pets) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final isSelected = _selectedPet?.id == pet.id;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColor.violetColor : Colors.transparent,
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedPet = pet),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: pet.image != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(pet.image!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pet.image == null
                          ? Icon(Icons.pets, color: Colors.grey)
                          : null,
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
                          Gap(4.h),
                          Text(
                            '${pet.behaviorCategory} • ${pet.weight}kg',
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColor.violetColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColor.whiteColor,
                          size: 16.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
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
        child: ElevatedButton(
          onPressed:
              _selectedPet != null ? () => _showConfirmationDialog() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.violetColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
          ),
          child: Text(
            'Xác nhận đặt phòng',
            style: AppTextStyle(context).buttonText,
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
  // Sử dụng Builder để có context mới
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => Builder(
      builder: (builderContext) => BookingConfirmationSheet(
        timeSlots: widget.timeSlots,
        pet: _selectedPet!,
        storeServiceId: widget.storeServiceId,
      ),
    ),
  );
}
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/views/store/layouts/booking_confirmation_layout.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ServiceTimeLayout extends ConsumerStatefulWidget {
  final int storeServiceId;
  final List<int> selectedPetIds;
  final int storeId;

  const ServiceTimeLayout({
    super.key,
    required this.storeServiceId,
    required this.selectedPetIds,
    required this.storeId
  });

  @override
  ConsumerState<ServiceTimeLayout> createState() => _ServiceTimeLayoutState();
}

class _ServiceTimeLayoutState extends ConsumerState<ServiceTimeLayout> {
  int? selectedTimeSlotId;
  List<ServiceTimeModel> availableTimeSlots = [];
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceTimes();
    });
  }

  Future<void> _loadServiceTimes() async {
    await ref.read(storeController.notifier).getServiceTimeWithStoreId(widget.storeServiceId, widget.storeId);
    if (mounted) {
      setState(() {
        final allTimeSlots = ref.read(storeController.notifier).serviceTime ?? [];
        // Lọc các time slot trong quá khứ
        availableTimeSlots = allTimeSlots.where((slot) {
          return slot.startTime.isAfter(DateTime.now());
        }).toList();
        
        // Sắp xếp theo thời gian
        availableTimeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    }
  }

  void _selectTimeSlot(int timeSlotId) {
    setState(() {
      selectedTimeSlotId = timeSlotId;
    });
  }

  void _confirmSelection() {
  if (selectedTimeSlotId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChoosePetForBookingLayout(
          serviceTypeId: widget.storeServiceId,
          timeSlotId: selectedTimeSlotId!,
          storeId: widget.storeId,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn thời gian')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(storeController);

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chọn thời gian',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColor.violetColor,
            ))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thời gian có sẵn',
                                style: AppTextStyle(context).title.copyWith(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text(
                              //   '${widget.selectedPetIds.length} thú cưng',
                              //   style: AppTextStyle(context).bodyText.copyWith(
                              //     color: AppColor.violetColor,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                            ],
                          ),
                          Gap(20.h),
                          _buildTimeSlotsList(),
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

  Widget _buildTimeSlotsList() {
    // Nhóm các time slot theo ngày
    Map<String, List<ServiceTimeModel>> groupedSlots = {};
    for (var slot in availableTimeSlots) {
      String date = dateFormatter.format(slot.startTime);
      if (!groupedSlots.containsKey(date)) {
        groupedSlots[date] = [];
      }
      groupedSlots[date]!.add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSlots.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                entry.key,
                style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 2,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final timeSlot = entry.value[index];
                final isSelected = selectedTimeSlotId == timeSlot.id;
                final isAvailable = timeSlot.currentPetOwner < timeSlot.limitPetOwner;

                return _buildTimeSlotCard(
                  timeSlot: timeSlot,
                  isSelected: isSelected,
                  isAvailable: isAvailable,
                );
              },
            ),
            Gap(16.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotCard({
    required ServiceTimeModel timeSlot,
    required bool isSelected,
    required bool isAvailable,
  }) {
    return GestureDetector(
      onTap: isAvailable ? () => _selectTimeSlot(timeSlot.id) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColor.violetColor 
              : isAvailable 
                  ? AppColor.whiteColor 
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
                ? AppColor.violetColor 
                : isAvailable 
                    ? Colors.grey[300]! 
                    : Colors.grey[200]!,
          ),
          boxShadow: isAvailable ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeFormatter.format(timeSlot.startTime),
              style: AppTextStyle(context).bodyText.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : isAvailable 
                        ? AppColor.blackColor 
                        : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(4.h),
            Text(
              '${timeSlot.currentPetOwner}/${timeSlot.limitPetOwner}',
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: isSelected 
                    ? Colors.white.withOpacity(0.8) 
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: selectedTimeSlotId != null ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Tiếp tục',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
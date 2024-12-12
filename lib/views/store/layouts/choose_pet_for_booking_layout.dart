import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/views/store/layouts/booking_confirmation_layout.dart';
import 'package:fluffypawuser/views/store/layouts/service_time_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:gap/gap.dart';

class ChoosePetForBookingLayout extends ConsumerStatefulWidget {
  // final int serviceTypeId;
  // final int timeSlotId;
  // final int storeId;
  final BookingDataModel bookingData;

  const ChoosePetForBookingLayout({super.key, required this.bookingData});

  @override
  ConsumerState<ChoosePetForBookingLayout> createState() =>
      _ChoosePetForBookingLayoutState();
}

class _ChoosePetForBookingLayoutState
    extends ConsumerState<ChoosePetForBookingLayout> {
  Set<int> selectedPetIds =
      {}; // Thay đổi từ single selection sang multiple selection
  List<PetModel> pets = [];
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      // Load cả pets và bookings
      await Future.wait([
        ref.read(petController.notifier).getPetList(),
        ref.read(storeController.notifier).getAllBookings(),
      ]);

      if (mounted) {
        setState(() {
          pets = ref.read(hiveStoreService).getPetInfo() ?? [];
          isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Có lỗi xảy ra khi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  // Future<void> _loadPets() async {
  //   await ref.read(petController.notifier).getPetList();
  //   if (mounted) {
  //     setState(() {
  //       pets = ref.read(hiveStoreService).getPetInfo() ?? [];
  //     });
  //   }
  // }

  void togglePetSelection(int petId) {
    setState(() {
      if (selectedPetIds.contains(petId)) {
        selectedPetIds.remove(petId);
      } else {
        selectedPetIds.add(petId);
      }
    });
  }

  void _confirmSelection() {
    if (selectedPetIds.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationLayout(
            bookingData: widget.bookingData,
            selectedPetIds: selectedPetIds.toList(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một thú cưng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(petController);

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chọn thú cưng',
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
          ? const Center(
              child: CircularProgressIndicator(
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
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Chọn thú cưng của bạn',
                          //       style: AppTextStyle(context).title.copyWith(
                          //         fontSize: 24.sp,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     Text(
                          //       '${selectedPetIds.length} đã chọn',
                          //       style: AppTextStyle(context).bodyText.copyWith(
                          //         color: AppColor.violetColor,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Gap(20.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return _buildPetCard(
                                pet: pet,
                                isSelected: selectedPetIds.contains(pet.id),
                                onTap: () => togglePetSelection(pet.id),
                              );
                            },
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

  Widget _buildPetCard({
    required PetModel pet,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isAvailable =
        isPetAvailableForTimeSlot(pet, widget.bookingData.timeSlot.startTime);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable ? AppColor.whiteColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.violetColor : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: pet.image ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.violetColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: AppTextStyle(context).subTitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColor.violetColor
                                  : AppColor.blackColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(4.h),
                      Text(
                        '${pet.weight} kg',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (!isAvailable)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          'Đã có lịch trong khung giờ này',
                          style: AppTextStyle(context).bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColor.violetColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  ),
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
              onPressed: selectedPetIds.isNotEmpty ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Xác nhận (${selectedPetIds.length})',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isPetAvailableForTimeSlot(PetModel pet, DateTime bookingTime) {
    // Lấy danh sách bookings từ state
    final bookings = ref.read(storeController.notifier).bookings;
    if (bookings == null) return true;

    // Kiểm tra xem pet có booking nào trùng thời gian không
    return !bookings.any((booking) {
      // Chỉ kiểm tra các booking có status là pending hoặc confirmed
      if (!['pending', 'confirmed'].contains(booking.status.toLowerCase())) {
        return false;
      }

      // Kiểm tra xem booking có phải của pet này không
      if (booking.petId != pet.id) {
        return false;
      }

      // Kiểm tra thời gian
      // Một booking được coi là trùng nếu:
      // 1. Cùng ngày
      // 2. Thời gian mới nằm trong khoảng thời gian của booking cũ
      final newBookingTime = bookingTime;
      final existingStartTime = booking.startTime;
      final existingEndTime = booking.endTime;

      return DateUtils.isSameDay(newBookingTime, existingStartTime) &&
              (newBookingTime.isAfter(existingStartTime) &&
                  newBookingTime.isBefore(existingEndTime)) ||
          newBookingTime.isAtSameMomentAs(existingStartTime);
    });
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/views/store/layouts/available_store_for_hotel_layout.dart';
import 'package:fluffypawuser/views/store/layouts/date_selection_for_hotel.dart';
import 'package:fluffypawuser/views/store/layouts/select_pet_for_hotel_date_layout.dart';
import 'package:fluffypawuser/views/store/layouts/store_service_time_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:intl/intl.dart';

class HotelDateSelectionScreen extends ConsumerStatefulWidget {
  final String hotelServiceName;
  final double price;
  final int serviceId;
  final String? backgroundImage;

  const HotelDateSelectionScreen({
    Key? key,
    required this.hotelServiceName,
    required this.price,
    required this.serviceId,
    this.backgroundImage,
  }) : super(key: key);

  @override
  ConsumerState<HotelDateSelectionScreen> createState() =>
      _HotelDateSelectionScreenState();
}

class _HotelDateSelectionScreenState
    extends ConsumerState<HotelDateSelectionScreen> {
  DateTime selectedCheckIn = DateTime.now();
  DateTime selectedCheckOut = DateTime.now().add(const Duration(days: 1));
  int adults = 1;
  int rooms = 1;
  int? selectedPetId;
  PetModel? selectedPet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image and Header Section
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height *
                    0.45, // Tăng chiều cao của phần background
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        Assets.image.ksChoMeo50055871549156792.path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.hotel, size: 50.sp),
                          );
                        },
                      ),
                    ),
                    // Back Button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10.h,
                      left: 16.w,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, size: 18.sp),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Title
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 60.h,
                      left: 20.w,
                      child: Text(
                        'ĐẶT PHÒNG KHÁCH SẠN',
                        style: AppTextStyle(context).title.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Main Content - Floating Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColor.violetColor,
                  width: 2.w,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Search
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        Gap(8.w),
                        Expanded(
                          child: Text(
                            '5 Đường D5, Q. Bình Thạnh, Thành Ph...',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  color: Colors.grey[600],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateSelectionScreen(
                            initialCheckIn: selectedCheckIn,
                            initialCheckOut: selectedCheckOut,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          selectedCheckIn = result['checkIn'];
                          selectedCheckOut = result['checkOut'];
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE', 'vi_VN')
                                    .format(selectedCheckIn), // Thứ trong tuần
                                style: AppTextStyle(context).bodyText,
                              ),
                              Text(
                                DateFormat('dd')
                                    .format(selectedCheckIn), // Ngày
                                style: AppTextStyle(context).title.copyWith(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.violetColor,
                                    ),
                              ),
                              Text(
                                'Tháng ${DateFormat('MM').format(selectedCheckIn)}', // Tháng
                                style: AppTextStyle(context).bodyText,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${selectedCheckOut.difference(selectedCheckIn).inDays}', // Số đêm
                                style: AppTextStyle(context).bodyText,
                              ),
                              Gap(4.w),
                              Icon(Icons.nights_stay, size: 16.sp),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('EEEE', 'vi_VN')
                                    .format(selectedCheckOut), // Thứ trong tuần
                                style: AppTextStyle(context).bodyText,
                              ),
                              Text(
                                DateFormat('dd')
                                    .format(selectedCheckOut), // Ngày
                                style: AppTextStyle(context).title.copyWith(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.violetColor,
                                    ),
                              ),
                              Text(
                                'Tháng ${DateFormat('MM').format(selectedCheckOut)}', // Tháng
                                style: AppTextStyle(context).bodyText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),

                  // Room and Guest Selection
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 Phòng',
                          style: AppTextStyle(context).bodyText.copyWith(
                                color: AppColor.violetColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<int>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SelectPetForHotelDateLayout(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                selectedPetId = result;
                                final pets =
                                    ref.read(hiveStoreService).getPetInfo() ??
                                        [];
                                try {
                                  selectedPet = pets.firstWhere(
                                    (pet) => pet.id == result,
                                  );
                                } catch (e) {
                                  // Xử lý trường hợp không tìm thấy pet
                                  selectedPet = null;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColor.violetColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedPet != null &&
                                    selectedPet!.image != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: CachedNetworkImage(
                                      imageUrl: selectedPet!.image!,
                                      width: 24.w,
                                      height: 24.w,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.pets, size: 16.sp),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.pets, size: 16.sp),
                                      ),
                                    ),
                                  ),
                                  Gap(8.w),
                                ],
                                Text(
                                  selectedPet?.name ?? 'Chọn thú cưng',
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            color: AppColor.violetColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                ),
                                Gap(4.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.sp,
                                  color: AppColor.violetColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Button
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).padding.bottom + 20.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailableStoresScreen(
                      checkIn: selectedCheckIn,
                      checkOut: selectedCheckOut,
                      rooms: rooms,
                      adults: adults,
                      serviceId: widget.serviceId,
                      serviceName: widget.hotelServiceName,
                      price: widget.price,
                      selectedPet: selectedPet,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Tìm kiếm',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

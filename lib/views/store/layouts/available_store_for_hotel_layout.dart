import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/views/store/layouts/store_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:intl/intl.dart';

class AvailableStoresScreen extends ConsumerStatefulWidget {
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int adults;
  final int serviceId;
  final String serviceName;
  final double price;
  final PetModel? selectedPet;

  const AvailableStoresScreen({
    Key? key,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.selectedPet
  }) : super(key: key);

  @override
  ConsumerState<AvailableStoresScreen> createState() =>
      _AvailableStoresScreenState();
}

class _AvailableStoresScreenState extends ConsumerState<AvailableStoresScreen> {
  Map<int, StoreModel> storeDetails = {};
  bool isLoading = true;
  List<ServiceTimeModel> availableTimeSlots = [];
  Set<int> availableStoreIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      // Load service time data using Future.delayed to avoid provider modification during build
      await Future.delayed(Duration.zero, () async {
        final controller = ref.read(storeController.notifier);
        await controller.getServiceTime(widget.serviceId);

        if (!mounted) return;

        final timeSlots = controller.serviceTime ?? [];

        // Filter time slots based on check-in and check-out dates
        availableTimeSlots = timeSlots.where((slot) {
          final slotDate = slot.startTime;
          return slotDate.isAfter(widget.checkIn.subtract(Duration(days: 1))) &&
              slotDate.isBefore(widget.checkOut.add(Duration(days: 1))) &&
              slot.currentPetOwner + widget.rooms <= slot.limitPetOwner;
        }).toList();

        // Get unique store IDs that have available slots
        availableStoreIds =
            availableTimeSlots.map((slot) => slot.storeId).toSet();

        // Load store details for available stores
        for (final storeId in availableStoreIds) {
          if (!mounted) return;
          await controller.getStoreById(storeId);
          final store = controller.selectedStore;
          if (store != null) {
            storeDetails[storeId] = store;
          }
        }
      });

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading available stores: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    final totalPrice = widget.price * nights * widget.rooms;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn chi nhánh',
              style: AppTextStyle(context).title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.serviceName,
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: AppColor.blackColor.withOpacity(0.6),
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Booking Summary Card
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(widget.checkIn),
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                Text(
                                  'Check-in',
                                  style: AppTextStyle(context).bodyTextSmall,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColor.violetColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$nights',
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            color: AppColor.violetColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                Gap(4.w),
                                Icon(
                                  Icons.nights_stay,
                                  size: 16.sp,
                                  color: AppColor.violetColor,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(widget.checkOut),
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                Text(
                                  'Check-out',
                                  style: AppTextStyle(context).bodyTextSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.rooms} Phòng, ${widget.adults} Thú cưng',
                            style: AppTextStyle(context).bodyText,
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  color: AppColor.violetColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Available Stores List
                Expanded(
                  child: availableStoreIds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64.sp,
                                color: Colors.grey[400],
                              ),
                              Gap(16.h),
                              Text(
                                'Không tìm thấy chi nhánh phù hợp',
                                style: AppTextStyle(context).subTitle.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: availableStoreIds.length,
                          itemBuilder: (context, index) {
                            final storeId = availableStoreIds.elementAt(index);
                            final store = storeDetails[storeId];
                            if (store == null) return SizedBox.shrink();

                            return Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  // Store Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12.r),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: store.logo,
                                      height: 150.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),

                                  // Store Details
                                  Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          store.name,
                                          style: AppTextStyle(context)
                                              .subTitle
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Gap(8.h),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber,
                                                size: 16.sp),
                                            Gap(4.w),
                                            Text(
                                              store.totalRating.toString(),
                                              style: AppTextStyle(context)
                                                  .bodyTextSmall,
                                            ),
                                          ],
                                        ),
                                        Gap(8.h),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: AppColor.violetColor,
                                                size: 16.sp),
                                            Gap(4.w),
                                            Expanded(
                                              child: Text(
                                                store.address,
                                                style: AppTextStyle(context)
                                                    .bodyTextSmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Gap(16.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '\$${widget.price.toStringAsFixed(2)}/đêm',
                                                    style: AppTextStyle(context)
                                                        .bodyText
                                                        .copyWith(
                                                          color: AppColor
                                                              .violetColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Tổng \$${totalPrice.toStringAsFixed(2)}',
                                                    style: AppTextStyle(context)
                                                        .bodyTextSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Lọc danh sách khung giờ cho store cụ thể
                                                final selectedStoreTimeSlots = availableTimeSlots
                                                    .where((slot) =>
                                                        slot.storeId ==
                                                            store.id &&
                                                        slot.startTime.isAfter(
                                                            widget.checkIn.subtract(
                                                                const Duration(
                                                                    days:
                                                                        1))) &&
                                                        slot.startTime.isBefore(
                                                            widget.checkOut.add(
                                                                const Duration(
                                                                    days: 1))))
                                                    .toList();

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoreDetailLayout(
                                                      storeId: store.id,
                                                      isFromBookingScreen: 1,
                                                      timeSlots:
                                                          selectedStoreTimeSlots, // Truyền list khung giờ đã lọc
                                                      serviceId:
                                                          widget.serviceId,
                                                      selectedPet: widget.selectedPet,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColor.whiteColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                              ),
                                              child: Text('Đặt ngay'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

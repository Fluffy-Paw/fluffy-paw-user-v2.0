import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:fluffypawuser/views/store/layouts/service_time_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

class ServiceTimeSelectionScreen extends ConsumerStatefulWidget {
  final int serviceId;
  final String serviceName;
  final double price;

  const ServiceTimeSelectionScreen({
    Key? key,
    required this.serviceId,
    required this.serviceName,
    required this.price,
  }) : super(key: key);

  @override
  ConsumerState<ServiceTimeSelectionScreen> createState() =>
      _ServiceTimeSelectionScreenState();
}

class _ServiceTimeSelectionScreenState
    extends ConsumerState<ServiceTimeSelectionScreen> {
  Map<int, StoreModel> storeDetails = {};
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  List<ServiceTimeModel> allTimeSlots = [];
  ServiceTimeModel? selectedTimeSlot;
  Set<DateTime> availableDates = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final controller = ref.read(storeController.notifier);
      await controller.getServiceTime(widget.serviceId);

      if (!mounted) return;

      final timeSlots = controller.serviceTime ?? [];

      // Extract available dates from time slots
      availableDates = timeSlots
          .map((slot) => DateTime(
              slot.startTime.year, slot.startTime.month, slot.startTime.day))
          .toSet();

      // If selected date has no slots, select first available date
      if (!availableDates.contains(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day))) {
        if (availableDates.isNotEmpty) {
          selectedDate = availableDates.first;
        }
      }

      // Load store details...
      final uniqueStoreIds = timeSlots.map((slot) => slot.storeId).toSet();
      for (final storeId in uniqueStoreIds) {
        if (!mounted) return;
        await controller.getStoreById(storeId);
        final store = controller.selectedStore;
        if (store != null) {
          storeDetails[storeId] = store;
        }
      }

      if (!mounted) return;
      setState(() {
        allTimeSlots = timeSlots;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading time slots: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Time Slot',
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
                _buildDateSelector(),
                Expanded(
                  child: _buildTimeSlotsList(),
                ),
              ],
            ),
      bottomNavigationBar: selectedTimeSlot != null ? _buildBottomBar() : null,
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
              onPressed: selectedTimeSlot != null ? onSelectTimeSlot : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Next',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    // Find the last available date
    final lastAvailableDate = availableDates.isEmpty
        ? DateTime.now()
        : availableDates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Calculate number of days to show
    final daysToShow = lastAvailableDate.difference(DateTime.now()).inDays + 1;

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      color: AppColor.whiteColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: daysToShow,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final normalizedDate = DateTime(date.year, date.month, date.day);

          // Skip dates that don't have available slots
          if (!availableDates.contains(normalizedDate)) {
            return SizedBox.shrink();
          }

          final isSelected = DateUtils.isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 60.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.violetColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColor.violetColor : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                  ),
                  Gap(4.h),
                  Text(
                    DateFormat('d').format(date),
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? Colors.white : AppColor.blackColor,
                        ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotsList() {
    final filteredSlots = allTimeSlots
        .where((slot) => DateUtils.isSameDay(slot.startTime, selectedDate))
        .toList();

    // Group by storeId
    // Group slots by storeId using a Map
    final groupedSlots = filteredSlots.fold<Map<int, List<ServiceTimeModel>>>(
      {},
      (map, slot) {
        if (!map.containsKey(slot.storeId)) {
          map[slot.storeId] = [];
        }
        map[slot.storeId]!.add(slot);
        return map;
      },
    );

    if (filteredSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            Gap(16.h),
            Text(
              'No available time slots',
              style: AppTextStyle(context).subTitle.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: groupedSlots.length,
      itemBuilder: (context, index) {
        final storeId = groupedSlots.keys.elementAt(index);
        final storeSlots = groupedSlots[storeId]!;
        final store = storeDetails[storeId];

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
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
              // Store Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: NetworkImage(store?.logo ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store?.name ?? 'Store',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
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
                                  store?.address ?? '',
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(
                                        color: Colors.grey[600],
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Time Slots Grid
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: storeSlots.map((slot) {
                    final isAvailable =
                        slot.currentPetOwner < slot.limitPetOwner;
                    return GestureDetector(
                      onTap: isAvailable
                          ? () {
                              setState(() {
                                selectedTimeSlot = slot;
                              });
                            }
                          : null,
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 64.w) / 3,
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 12.w,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? slot == selectedTimeSlot
                                  ? AppColor.violetColor
                                  : AppColor.violetColor.withOpacity(0.1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isAvailable
                                ? slot == selectedTimeSlot
                                    ? AppColor.violetColor
                                    : AppColor.violetColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('HH:mm').format(slot.startTime),
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isAvailable
                                        ? slot == selectedTimeSlot
                                            ? Colors.white
                                            : AppColor.violetColor
                                        : Colors.grey[600],
                                  ),
                            ),
                            Gap(4.h),
                            Text(
                              '${slot.currentPetOwner}/${slot.limitPetOwner}',
                              style:
                                  AppTextStyle(context).bodyTextSmall.copyWith(
                                        color: isAvailable
                                            ? slot == selectedTimeSlot
                                                ? Colors.white
                                                : AppColor.violetColor
                                                    .withOpacity(0.8)
                                            : Colors.grey[600],
                                      ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onSelectTimeSlot() async {
  if (selectedTimeSlot == null) return;
  
  try {
    final controller = ref.read(storeController.notifier);
    
    // Load store service first
    await controller.getStoreServiceByStoreId(selectedTimeSlot!.storeId);
    
    final service = controller.storeServices?.firstWhere(
      (s) => s.id == widget.serviceId,
    );
    
    if (service == null) {
      throw Exception('Service not found');
    }

    final store = storeDetails[selectedTimeSlot!.storeId];
    if (store == null) {
      throw Exception('Store not found'); 
    }

    final bookingData = BookingDataModel(
      store: store,
      timeSlot: selectedTimeSlot!,
      service: service,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoosePetForBookingLayout(
            bookingData: bookingData,
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
}

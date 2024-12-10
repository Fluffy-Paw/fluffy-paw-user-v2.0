import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/routes.dart';
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

  const ServiceTimeLayout(
      {super.key,
      required this.storeServiceId,
      required this.selectedPetIds,
      required this.storeId});

  @override
  ConsumerState<ServiceTimeLayout> createState() => _ServiceTimeLayoutState();
}

class _ServiceTimeLayoutState extends ConsumerState<ServiceTimeLayout> {
  int? selectedTimeSlotId;
  List<ServiceTimeModel> availableTimeSlots = [];
  // Thêm biến để track store của time slot đã chọn
  StoreModel? selectedStore;
  StoreServiceModel? selectedService;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    print('ServiceTimeLayout initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    print('Loading data...');

    try {
      final controller = ref.read(storeController.notifier);

      // Chỉ load time slots của service
      await controller.getServiceTime(widget.storeServiceId);

      if (!mounted) return;

      setState(() {
        final allTimeSlots = controller.serviceTime ?? [];
        print('Loaded ${allTimeSlots.length} time slots');

        availableTimeSlots = allTimeSlots.where((slot) {
          return slot.startTime.isAfter(DateTime.now());
        }).toList();

        print('${availableTimeSlots.length} available time slots');
        availableTimeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi khi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadServiceTimes() async {
    print('Loading service times...');
    await ref
        .read(storeController.notifier)
        .getServiceTimeWithStoreId(widget.storeServiceId, widget.storeId);
    if (mounted) {
      setState(() {
        final allTimeSlots =
            ref.read(storeController.notifier).serviceTime ?? [];
        print('Loaded ${allTimeSlots.length} time slots');
        // Lọc các time slot trong quá khứ
        availableTimeSlots = allTimeSlots.where((slot) {
          return slot.startTime.isAfter(DateTime.now());
        }).toList();
        print('${availableTimeSlots.length} available time slots');

        // Sắp xếp theo thời gian
        availableTimeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    }
  }

  void _selectTimeSlot(int timeSlotId) {
    print('_selectTimeSlot called with ID: $timeSlotId');
    setState(() {
      selectedTimeSlotId = timeSlotId;
    });
    print('selectedTimeSlotId after setState: $selectedTimeSlotId');
  }

  Future<void> _confirmSelection() async {
    if (selectedTimeSlotId != null) {
      try {
        final selectedTimeSlot = availableTimeSlots.firstWhere(
          (slot) => slot.id == selectedTimeSlotId,
        );

        final controller = ref.read(storeController.notifier);

        await Future.wait([
          controller.getStoreById(selectedTimeSlot.storeId),
          controller.getStoreServiceByStoreId(selectedTimeSlot.storeId),
        ]);

        final store = controller.selectedStore;
        final services = controller.storeServices;

        if (store == null || services == null) {
          throw Exception('Không thể tải thông tin cửa hàng hoặc dịch vụ');
        }

        final service = services.firstWhere(
          (s) => s.id == widget.storeServiceId,
        );

        final bookingData = BookingDataModel(
          store: store,
          timeSlot: selectedTimeSlot,
          service: service,
        );

        Navigator.pushNamed(
          context,
          Routes.choosePetForBooking,
          arguments: ChoosePetForBookingArguments(bookingData: bookingData),
        );
      } catch (e) {
        print('Error in _confirmSelection: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
        );
      }
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
                final isAvailable =
                    timeSlot.currentPetOwner < timeSlot.limitPetOwner;

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
      onTap: isAvailable
          ? () {
              print('Time slot tapped - ID: ${timeSlot.id}'); // Thêm log
              _selectTimeSlot(timeSlot.id);
            }
          : null,
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
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
    print('_buildBottomBar - selectedTimeSlotId: $selectedTimeSlotId');
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
              onPressed: () {
                print('Next button pressed'); // Thêm log
                if (selectedTimeSlotId != null) {
                  print('Calling _confirmSelection'); // Thêm log
                  _confirmSelection();
                }
              },
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

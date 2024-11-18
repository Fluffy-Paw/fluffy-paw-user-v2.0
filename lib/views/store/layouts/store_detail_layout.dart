import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/choose_pet_for_booking_view.dart';
import 'package:fluffypawuser/views/store/components/store_location_map.dart';
import 'package:fluffypawuser/views/store/layouts/booking_time_selection_layout.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StoreDetailLayout extends ConsumerStatefulWidget {
  final int storeId;

  const StoreDetailLayout({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  @override
  ConsumerState<StoreDetailLayout> createState() => _StoreDetailLayoutState();
}

class _StoreDetailLayoutState extends ConsumerState<StoreDetailLayout> {
  
  StoreServiceModel? selectedService;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadStoreData());
  }
  

  Future<void> _loadStoreData() async {
    try {
      await ref.read(storeController.notifier).getStoreById(widget.storeId);
      await ref
          .read(storeController.notifier)
          .getStoreServiceByStoreId(widget.storeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading store data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: Consumer(
        builder: (context, ref, child) {
          final isLoading = ref.watch(storeController);
          final store = ref.watch(storeController.notifier).selectedStore;
          final services = ref.watch(storeController.notifier).storeServices;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store == null) {
            return const Center(child: Text('Store not found'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(store),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStoreInfoCard(store),
                    Gap(16.h),
                    if (services != null) _buildServicesList(services),
                    Gap(16.h),
                    _buildContactInfo(store),
                    Gap(16.h),
                    _buildLocation(store),
                    Gap(100.h), // Space for bottom bar
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar(StoreModel store) {
    return SliverAppBar(
      expandedHeight: 250.h,
      pinned: true,
      backgroundColor: AppColor.whiteColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: store.logo,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.store, size: 50.sp),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: CircleAvatar(
          backgroundColor: AppColor.whiteColor.withOpacity(0.9),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                size: 18.sp, color: AppColor.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard(StoreModel store) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
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
            store.name,
            style: AppTextStyle(context).title.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Gap(8.h),
          Text(
            store.brandName,
            style: AppTextStyle(context).bodyText.copyWith(
                  color: AppColor.blackColor.withOpacity(0.6),
                ),
          ),
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20.sp),
              Gap(4.w),
              Text(
                '${store.totalRating}/5',
                style: AppTextStyle(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Gap(16.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: store.status ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      store.status ? Icons.check_circle : Icons.cancel,
                      size: 16.sp,
                      color: store.status ? Colors.green : Colors.red,
                    ),
                    Gap(4.w),
                    Text(
                      store.status ? 'Đang mở cửa' : 'Đã đóng cửa',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: store.status ? Colors.green : Colors.red,
                          ),
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

  Widget _buildServicesList(List<StoreServiceModel> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Dịch vụ',
            style: AppTextStyle(context).title.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Gap(12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: services.length,
          itemBuilder: (context, index) => _buildServiceCard(services[index]),
        ),
      ],
    );
  }

  Widget _buildServiceCard(StoreServiceModel service) {
    final isSelected = selectedService?.id == service.id;
    final isHotelService = service.serviceTypeName.toLowerCase().contains('hotel') || 
                          service.serviceTypeName.toLowerCase().contains('phòng');

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
        onTap: () => setState(() => selectedService = service),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: AppTextStyle(context).subTitle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isHotelService)
                              Container(
                                margin: EdgeInsets.only(left: 8.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.violetColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'Hotel',
                                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                                    color: AppColor.violetColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Gap(4.h),
                        Text(
                          service.serviceTypeName,
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.blackColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${service.cost}',
                    style: AppTextStyle(context).title.copyWith(
                      color: AppColor.violetColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                  Gap(4.w),
                  Text(
                    service.duration,
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Gap(16.w),
                  Icon(Icons.star, size: 16.sp, color: Colors.amber),
                  Gap(4.w),
                  Text(
                    service.totalRating.toString(),
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(StoreModel store) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
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
            'Thông tin liên hệ',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(16.h),
          _buildContactRow(Icons.phone, 'Số điện thoại', store.phone),
          Gap(12.h),
          _buildContactRow(Icons.location_on, 'Địa chỉ', store.address),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                label,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.blackColor.withOpacity(0.6),
                    ),
              ),
              Gap(4.h),
              Text(
                value,
                style: AppTextStyle(context).bodyText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(StoreModel store) {
  return StoreLocationWidget(store: store);
}

  Widget _buildBottomBar() {
  final isHotelService = selectedService?.serviceTypeName.toLowerCase().contains('hotel') == true || 
                        selectedService?.serviceTypeName.toLowerCase().contains('phòng') == true;

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
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: selectedService != null
                ? () {
                    if (isHotelService) {
                      // Chuyển sang booking time với service ID và giá
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTimeSelectionLayout(
                            storeServiceId: selectedService!.id,
                            price: selectedService!.cost.toDouble(), // Truyền giá service
                          ),
                        ),
                      );
                    } else {
                      // Dịch vụ thông thường
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChoosePetForBookingView(
                            serviceTypeId: selectedService!.id,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.violetColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
            ),
            child: Text(
              isHotelService ? 'Đặt phòng' : 'Đặt dịch vụ',
              style: AppTextStyle(context).buttonText,
            ),
          ),
        ),
        Gap(16.w),
        Container(
          decoration: BoxDecoration(
            color: AppColor.violetColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.chat,
              color: AppColor.violetColor,
              size: 24.sp,
            ),
            onPressed: () {
              // Xử lý chức năng chat
            },
          ),
        ),
      ],
    ),
  );
}
}

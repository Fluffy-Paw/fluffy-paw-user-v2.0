import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/rating/rating_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/choose_pet_for_booking_view.dart';
import 'package:fluffypawuser/views/store/components/store_location_map.dart';
import 'package:fluffypawuser/views/store/layouts/booking_confirm_sheet_for_hotel.dart';
import 'package:fluffypawuser/views/store/layouts/booking_time_selection_layout.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:fluffypawuser/views/store/layouts/service_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StoreDetailLayout extends ConsumerStatefulWidget {
  final int storeId;
  final int? isFromBookingScreen;
  final List<ServiceTimeModel>? timeSlots;
  final int? serviceId;
  final PetModel? selectedPet;

  const StoreDetailLayout(
      {Key? key,
      required this.storeId,
      this.isFromBookingScreen,
      this.timeSlots,
      this.serviceId,
      this.selectedPet})
      : super(key: key);

  @override
  ConsumerState<StoreDetailLayout> createState() => _StoreDetailLayoutState();
}

class _StoreDetailLayoutState extends ConsumerState<StoreDetailLayout> {
  StoreServiceModel? selectedService;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Sử dụng Future.delayed để đảm bảo widget đã được mount hoàn toàn
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      await _loadStoreData();
      if (!mounted) return;
      // Sử dụng ref.read thay vì ref.watch trong Future
      await ref
          .read(bookingRatingController.notifier)
          .getStoreRatings(widget.storeId);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Giải phóng controller khi widget bị hủy
    super.dispose();
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
                    _buildRatings(context), // Thêm widget ratings vào đây
                    if (services != null && widget.isFromBookingScreen == null)
                      _buildServicesList(services),
                    Gap(16.h),
                    _buildContactInfo(store),
                    Gap(16.h),
                    _buildLocation(store),
                    Gap(100.h),
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
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColor.whiteColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel với PageController
            PageView.builder(
              controller: _pageController, // Thêm controller
              itemCount: store.files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final file = store.files[index];
                return GestureDetector(
                  // Thêm GestureDetector để xử lý tap
                  onTap: () {
                    // Xử lý khi tap vào ảnh (nếu cần)
                  },
                  child: CachedNetworkImage(
                    imageUrl: file.file,
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
                        Icons.image_not_supported_rounded,
                        size: 50.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Thêm nút điều hướng trái/phải
            if (store.files.length > 1) ...[
              Positioned(
                left: 16.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentImageIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 24.sp,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentImageIndex < store.files.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 24.sp,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Image indicators
            if (store.files.length > 1)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: store.files.asMap().entries.map((entry) {
                    return Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? AppColor.violetColor
                            : AppColor.whiteColor.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Store info overlay
            Positioned(
              bottom: 40.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store logo
                  if (store.logo.isNotEmpty)
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.whiteColor,
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: store.logo,
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
                    ),
                  Gap(12.h),

                  // Rating and status
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16.sp,
                            ),
                            Gap(4.w),
                            Text(
                              store.totalRating.toStringAsFixed(1),
                              style:
                                  AppTextStyle(context).bodyTextSmall.copyWith(
                                        color: AppColor.whiteColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      Gap(8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: store.status
                              ? Colors.green.withOpacity(0.8)
                              : Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          store.status ? 'Đang mở cửa' : 'Đã đóng cửa',
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: AppColor.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
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
      // Back button
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.whiteColor.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 18.sp,
              color: AppColor.blackColor,
            ),
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
    final isHotelService =
        service.serviceTypeName.toLowerCase().contains('hotel') ||
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailLayout(
              service: service,
              storeId: widget.storeId,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: CachedNetworkImage(
                imageUrl: service.image,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  height: 180.h,
                  child: Icon(Icons.image_not_supported, size: 40.sp),
                ),
              ),
            ),

            // Content section
            Padding(
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
                                    style:
                                        AppTextStyle(context).subTitle.copyWith(
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
                                      color:
                                          AppColor.violetColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Hotel',
                                      style: AppTextStyle(context)
                                          .bodyTextSmall
                                          .copyWith(
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
                              style: AppTextStyle(context)
                                  .bodyTextSmall
                                  .copyWith(
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
                  // Service stats
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
                        '${service.totalRating}',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      Gap(16.w),
                      Icon(Icons.bookmark, size: 16.sp, color: Colors.grey),
                      Gap(4.w),
                      Text(
                        '${service.bookingCount} bookings',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey,
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
          // Nút Chat
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Xử lý chức năng chat
              },
              icon: Icon(
                Icons.chat,
                color: Colors.white,
                size: 24.sp,
              ),
              label: Text(
                'Chat with Store',
                style: AppTextStyle(context).buttonText,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          // Nút Xác nhận (chỉ hiện khi có isFromBookingScreen)
          if (widget.isFromBookingScreen != null) ...[
            Gap(12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BookingConfirmationSheet(
                      timeSlots:
                          widget.timeSlots ?? [], // Truyền danh sách time slots
                      pet: widget.selectedPet!, // Truyền thông tin pet đã chọn
                      storeServiceId: widget.serviceId ?? 0,
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
                  'Xác nhận',
                  style: AppTextStyle(context).buttonText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatings(BuildContext context) {
    final isLoading = ref.watch(bookingRatingController);
    final ratings = ref.watch(bookingRatingController.notifier).ratings;
    final controller = ref.read(bookingRatingController.notifier);

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final hasRatings = ratings != null && ratings.isNotEmpty;
    final averageRating = hasRatings ? controller.getAverageStoreRating() : 0.0;
    final stats = hasRatings ? controller.getStoreRatingStats() : {};
    final total = hasRatings ? controller.getTotalStoreRatings() : 0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá',
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20.sp),
                    Gap(4.w),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      ' ($total)',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            final count = stats[stars]?['count'] ?? 0;
            final percent = (stats[stars]?['percentage'] ?? '0').toString();

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 30.w,
                    child: Text(
                      '$stars★',
                      style: AppTextStyle(context).bodyTextSmall,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: (double.tryParse(percent) ?? 0) / 100,
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColor.violetColor,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30.w,
                    child: Text(
                      count.toString(),
                      textAlign: TextAlign.end,
                      style: AppTextStyle(context).bodyTextSmall,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (!hasRatings)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  'Chưa có đánh giá nào',
                  style: AppTextStyle(context).bodyText.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),
          if (hasRatings) ...[
            Gap(16.h),
            ...ratings
                .take(5)
                .map((rating) => _buildRatingItem(context, rating)),
            if (ratings.length > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to all store ratings screen
                    // TODO: Tạo màn hình xem tất cả đánh giá của store
                  },
                  child: Text(
                    'Xem tất cả đánh giá',
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: AppColor.violetColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, BookingRating rating) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: rating.avatar != null
                    ? CachedNetworkImageProvider(rating.avatar!)
                    : null,
                child: rating.avatar == null
                    ? Text(
                        rating.fullName?[0].toUpperCase() ?? 'U',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: AppColor.whiteColor,
                            ),
                      )
                    : null,
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.fullName ?? 'User #${rating.petOwnerId}',
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.storeVote
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.description != null) ...[
            Gap(12.h),
            Text(
              rating.description!,
              style: AppTextStyle(context).bodyText,
            ),
          ],
          if (rating.image != null) ...[
            Gap(12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: rating.image!,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/rating/rating_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/models/store/store_datetime_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/layouts/booking_time_selection_layout.dart';
import 'package:fluffypawuser/views/store/layouts/hotel_date_selection_layout.dart';
import 'package:fluffypawuser/views/store/layouts/service_rating_screen.dart';
import 'package:fluffypawuser/views/store/layouts/service_time_layout.dart';
import 'package:fluffypawuser/views/store/layouts/store_service_time_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ServiceDetailLayout extends ConsumerStatefulWidget {
  final StoreServiceModel service;
  final int? storeId;

  const ServiceDetailLayout({
    Key? key,
    required this.service,
    this.storeId,
  }) : super(key: key);

  @override
  ConsumerState<ServiceDetailLayout> createState() =>
      _ServiceDetailLayoutState();
}

class _ServiceDetailLayoutState extends ConsumerState<ServiceDetailLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookingRatingController.notifier)
          .getServiceRatings(widget.service.id);
      // Fetch stores data when component mounts
      ref
          .read(storeController.notifier)
          .getStoresByServiceId(widget.service.id);
      ref.read(storeController.notifier).getBrandById(widget.service.brandId);
    });
  }
  // final StoreServiceModel service;
  // final int storeId;

  // const ServiceDetailLayout(
  //     {Key? key, required this.service, required this.storeId})
  //     : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Gap(20.h),
                  _buildBrandSection(context), // Add brand section here
                  Gap(20.h),
                  _buildDescription(context),
                  Gap(20.h),
                  _buildCertificates(context),
                  Gap(20.h),
                  _buildServiceStats(context),
                  Gap(20.h),
                  _buildStoresSection(context),
                  Gap(20.h),
                  _buildRatings(context),
                  Gap(100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
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
    final averageRating = hasRatings ? controller.getAverageRating() : 0.0;
    final distribution = hasRatings ? controller.getRatingDistribution()['service'] ?? {} : {};
    final total = hasRatings ? ratings.length : 0;

    return Column(
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
          final count = distribution[stars] ?? 0;
          final percent = total == 0 ? 0.0 : (count / total * 100);

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Text(
                  '$stars',
                  style: AppTextStyle(context).bodyTextSmall,
                ),
                Gap(4.w),
                Icon(Icons.star, color: Colors.amber, size: 14.sp),
                Gap(8.w),
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
                        widthFactor: percent / 100,
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
                Gap(8.w),
                Text(
                  count.toString(),
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey[600],
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
          ...ratings.take(5).map((rating) => _buildRatingItem(context, rating)),
          if (ratings.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceRatingsScreen(
                        serviceId: widget.service.id,
                        serviceName: widget.service.name,
                      ),
                    ),
                  );
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
    );
  }

  Widget _buildStoresSection(BuildContext context) {
    final isLoading = ref.watch(storeController);
    final stores = ref.watch(storeController.notifier).stores;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (stores == null || stores.isEmpty) {
      return SizedBox.shrink();
    }

    // Sort stores by rating
    final sortedStores = List.from(stores)
      ..sort((a, b) => b.totalRating.compareTo(a.totalRating));

    // Take top 2 stores
    final topStores = sortedStores.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các chi nhánh nổi bật',
          style: AppTextStyle(context).title.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(16.h),
        ...topStores.map((store) => _buildStoreItem(context, store)),
        if (stores.length > 2)
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to all branches screen
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AllBranchesScreen(
                //       serviceId: widget.service.id,
                //       stores: stores,
                //     ),
                //   ),
                // );
              },
              child: Text(
                'Xem tất cả chi nhánh',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: AppColor.violetColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStoreItem(BuildContext context, StoreDateTimeModel store) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: NetworkImage(store.operatingLicense),
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
                      store.name,
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16.sp),
                        Gap(4.w),
                        Text(
                          store.totalRating.toString(),
                          style: AppTextStyle(context).bodyTextSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: AppColor.violetColor, size: 16.sp),
              Gap(4.w),
              Expanded(
                child: Text(
                  store.address,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.phone_outlined,
                  color: AppColor.violetColor, size: 16.sp),
              Gap(4.w),
              Text(
                store.phone,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, BookingRating rating) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.violetColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    'U',
                    style: AppTextStyle(context).title.copyWith(
                          color: AppColor.violetColor,
                        ),
                  ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User #${rating.petOwnerId}',
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.serviceVote
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

  Widget _buildBrandSection(BuildContext context) {
    // Watch cả state và brand
    final isLoading = ref.watch(storeController);
    final controller = ref.watch(storeController.notifier);
    final brand = controller.brand;

    // Debug logs
    debugPrint('Brand loading state: $isLoading');
    //debugPrint('Brand data: ${brand?.toMap()}');

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (brand == null) {
      debugPrint('Brand is null');
      return const SizedBox.shrink();
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
            offset: const Offset(0, 2),
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
                'Thương hiệu',
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
                    Icon(Icons.verified,
                        color: AppColor.violetColor, size: 20.sp),
                    Gap(4.w),
                    Text(
                      'Verified',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.violetColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: brand.logo,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.business, size: 40.sp),
                  ),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name,
                      style: AppTextStyle(context).subTitle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Gap(8.h),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            color: AppColor.violetColor, size: 16.sp),
                        Gap(4.w),
                        Text(
                          brand.hotline,
                          style: AppTextStyle(context).bodyTextSmall,
                        ),
                      ],
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        Icon(Icons.email,
                            color: AppColor.violetColor, size: 16.sp),
                        Gap(4.w),
                        Text(
                          brand.brandEmail,
                          style: AppTextStyle(context).bodyTextSmall,
                        ),
                      ],
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: AppColor.violetColor, size: 16.sp),
                        Gap(4.w),
                        Expanded(
                          child: Text(
                            brand.address,
                            style: AppTextStyle(context).bodyTextSmall,
                            maxLines: 2,
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
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColor.whiteColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.service.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, size: 50.sp),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service.name,
                    style: AppTextStyle(context).title.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Gap(4.h),
                  Text(
                    widget.service.serviceTypeName,
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: AppColor.blackColor.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColor.violetColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '\$${widget.service.cost}',
                style: AppTextStyle(context).subTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyle(context).subTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(12.h),
        Text(
          widget.service.description,
          style: AppTextStyle(context).bodyText.copyWith(
                color: AppColor.blackColor.withOpacity(0.7),
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildCertificates(BuildContext context) {
    if (widget.service.certificate.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificates',
          style: AppTextStyle(context).subTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(12.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.service.certificate.length,
            separatorBuilder: (context, index) => Gap(12.w),
            itemBuilder: (context, index) {
              final certificate = widget.service.certificate[index];
              return Container(
                width: 200.w,
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: certificate.file,
                        width: 80.w,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              certificate.name,
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(4.h),
                            Text(
                              certificate.description,
                              style: AppTextStyle(context)
                                  .bodyTextSmall
                                  .copyWith(
                                    color: AppColor.blackColor.withOpacity(0.6),
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceStats(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.access_time,
            'Duration',
            widget.service.duration,
          ),
          _buildStatItem(
            context,
            Icons.star,
            'Rating',
            '${widget.service.totalRating}',
          ),
          _buildStatItem(
            context,
            Icons.bookmark,
            'Bookings',
            widget.service.bookingCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColor.violetColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColor.violetColor,
            size: 24.sp,
          ),
        ),
        Gap(8.h),
        Text(
          label,
          style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: AppColor.blackColor.withOpacity(0.6),
              ),
        ),
        Gap(4.h),
        Text(
          value,
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  // In ServiceDetailLayout, update the _buildBottomBar method
  Widget _buildBottomBar(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.blackColor.withOpacity(0.6),
                      ),
                ),
                Text(
                  '\$${widget.service.cost}',
                  style: AppTextStyle(context).title.copyWith(
                        color: AppColor.violetColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Gap(16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Check if the service is a hotel service
                if (widget.service.serviceTypeId == 3) {
                  if (widget.storeId == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDateSelectionScreen(
                          hotelServiceName: widget.service.name,
                          price: widget.service.cost.toDouble(),
                          serviceId: widget.service.id,
                        ),
                      ),
                    );
                  } else {
                    // Nếu là dịch vụ hotel và có storeId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingTimeSelectionLayout(
                          storeServiceId: widget.service.id,
                          price: widget.service.cost.toDouble(),
                          storeId: widget.storeId!,
                        ),
                      ),
                    );
                  }
                } else {
                  if (widget.storeId == null) {
                    // Nếu storeId null, chuyển đến ServiceTimeSelectionScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceTimeSelectionScreen(
                          serviceId: widget.service.id,
                          serviceName: widget.service.name,
                          price: widget.service.cost.toDouble(),
                        ),
                      ),
                    );
                  } else {
                    // Nếu có storeId, chuyển đến ServiceTimeLayout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceTimeLayout(
                          storeServiceId: widget.service.id,
                          selectedPetIds: [],
                          storeId: widget.storeId!,
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                widget.service.serviceTypeId == 3 ||
                        widget.service.serviceTypeName
                            .toLowerCase()
                            .contains('phòng')
                    ? 'Book Room'
                    : 'View Available Times',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

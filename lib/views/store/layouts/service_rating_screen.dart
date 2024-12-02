import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/rating/rating_controller.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ServiceRatingsScreen extends ConsumerStatefulWidget {
  final int serviceId;
  final String serviceName;

  const ServiceRatingsScreen({
    Key? key,
    required this.serviceId,
    required this.serviceName,
  }) : super(key: key);

  @override
  ConsumerState<ServiceRatingsScreen> createState() => _ServiceRatingsScreenState();
}

class _ServiceRatingsScreenState extends ConsumerState<ServiceRatingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    await ref.read(bookingRatingController.notifier).getServiceRatings(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingRatingController);
    final controller = ref.watch(bookingRatingController.notifier);
    final ratings = controller.ratings;
    final distributions = controller.getRatingDistribution();
    final serviceDistribution = distributions['service'] ?? {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    final averageRating = controller.getAverageRating(isService: true);

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Đánh giá dịch vụ',
          style: AppTextStyle(context).title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRatings,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildRatingSummary(averageRating, serviceDistribution),
              _buildRatingFilters(),
              _buildRatingsList(isLoading, ratings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary(double averageRating, Map<int, int> distribution) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: AppTextStyle(context).title.copyWith(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.violetColor,
                ),
              ),
              Gap(8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20.sp,
                    )),
                  ),
                  Gap(4.h),
                  Text(
                    '$total đánh giá',
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                ],
              ),
            ],
          ),
          Gap(20.h),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            final count = distribution[stars] ?? 0;
            final percent = total == 0 ? 0.0 : (count / total * 100);
            
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Text(
                    '$stars',
                    style: AppTextStyle(context).bodyText,
                  ),
                  Gap(4.w),
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  Gap(8.w),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percent / 100,
                          child: Container(
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColor.violetColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(8.w),
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: AppTextStyle(context).bodyTextSmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingFilters() {
    final controller = ref.watch(bookingRatingController.notifier);
    final selectedFilter = controller.selectedFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Tất cả',
            isSelected: selectedFilter == null,
            onTap: () => controller.getServiceRatings(widget.serviceId),
          ),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            return _buildFilterChip(
              label: '$stars sao',
              isSelected: selectedFilter == stars,
              onTap: () => controller.getServiceRatings(
                widget.serviceId,
                filterStar: stars,
                isService: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.violetColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColor.violetColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsList(bool isLoading, List<BookingRating>? ratings) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (ratings == null || ratings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'Chưa có đánh giá nào',
            style: AppTextStyle(context).bodyText,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: ratings.length,
      itemBuilder: (context, index) => _buildRatingItem(ratings[index]),
    );
  }

  Widget _buildRatingItem(BookingRating rating) {
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
                          index < rating.serviceVote ? Icons.star : Icons.star_border,
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
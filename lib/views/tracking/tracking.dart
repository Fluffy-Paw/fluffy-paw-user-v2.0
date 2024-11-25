import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/tracking/tracking_controller.dart';
import 'package:fluffypawuser/models/tracking/tracking_file_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends ConsumerWidget {
  final int bookingId;

  const TrackingScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
          ? AppColor.blackColor
          : AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Tracking Order #$bookingId',
              style: AppTextStyle(context).title.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View order progress',
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: Colors.grey,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final trackingState = ref.watch(trackingControllerProvider(bookingId));

          return trackingState.when(
            loading: () => _buildLoadingShimmer(),
            error: (error, stack) => _buildErrorState(context, ref),
            data: (trackingList) {
              if (trackingList.isEmpty) {
                return _buildEmptyState(context, ref);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(trackingControllerProvider(bookingId));
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                  itemCount: trackingList.length,
                  itemBuilder: (context, index) {
                    final tracking = trackingList[index];
                    final isLastItem = index == trackingList.length - 1;
                    
                    return TrackingMessageCard(
                      tracking: tracking,
                      isLastItem: isLastItem,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(trackingControllerProvider(bookingId));
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColor.violetColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pending_actions_outlined,
                      size: 48.sp,
                      color: AppColor.violetColor,
                    ),
                  ),
                  Gap(16.h),
                  Text(
                    'No Tracking Updates Yet',
                    style: AppTextStyle(context).title.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.violetColor,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'Service tracking details will appear here\nwhen the service begins',
                    textAlign: TextAlign.center,
                    style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Gap(24.h),
                  Text(
                    'Pull down to refresh',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red,
            ),
          ),
          Gap(16.h),
          Text(
            'Something went wrong',
            style: AppTextStyle(context).title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Gap(8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Failed to load tracking updates.\nPlease try again.',
              textAlign: TextAlign.center,
              style: AppTextStyle(context).bodyText.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Gap(24.h),
          TextButton.icon(
            onPressed: () {
              ref.refresh(trackingControllerProvider(bookingId));
            },
            icon: Icon(
              Icons.refresh,
              size: 20.sp,
              color: AppColor.violetColor,
            ),
            label: Text(
              'Retry',
              style: AppTextStyle(context).buttonText.copyWith(
                color: AppColor.violetColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100.w,
                      height: 10.h,
                      color: Colors.white,
                    ),
                    Gap(8.h),
                    Container(
                      width: double.infinity,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackingMessageCard extends StatelessWidget {
  final TrackingInfo tracking;
  final bool isLastItem;

  const TrackingMessageCard({
    Key? key,
    required this.tracking,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColor.violetColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLastItem)
                Container(
                  width: 2.w,
                  height: 50.h,
                  color: AppColor.violetColor.withOpacity(0.3),
                ),
            ],
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(tracking.uploadDate.toLocal()),
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Gap(4.h),
                _buildContentCard(context),
                Gap(16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tracking.files.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(
                images: tracking.files.map((e) => e.file).toList(),
              ),
            ),
          );
        }
      },
      child: Container(
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
            if (tracking.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  tracking.description,
                  style: AppTextStyle(context).bodyText,
                  softWrap: true,
                ),
              ),
            if (tracking.files.isNotEmpty)
              ClipRRect(
                borderRadius: tracking.description.isEmpty
                    ? BorderRadius.circular(12.r)
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                child: tracking.files.length == 1
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: tracking.files[0].file,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.w,
                        ),
                        itemCount: tracking.files.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: tracking.files[index].file,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final List<String> images;

  const ImageViewer({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 48.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
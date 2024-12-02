import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StoreCard extends StatelessWidget {
  final StoreModel store;

  const StoreCard({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          context.nav.pushNamed(
            Routes.storeDetail,
            arguments: {
              'serviceTypeId':
                  store.id, // Changed from storeId to serviceTypeId
              'isFromBookingScreen': null,
            },
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStoreImage(),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreName(context),
                    Gap(4.h),
                    _buildBrandName(context),
                    Gap(8.h),
                    _buildAddress(context),
                    Gap(8.h),
                    _buildBottomInfo(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: CachedNetworkImage(
        imageUrl: store.logo,
        width: 80.w,
        height: 80.w,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.store, size: 40.w, color: Colors.grey),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.store, size: 40.w, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStoreName(BuildContext context) {
    return Text(
      store.name,
      style: AppTextStyle(context).subTitle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBrandName(BuildContext context) {
    return Text(
      store.brandName,
      style: AppTextStyle(context).bodyTextSmall.copyWith(
            color: AppColor.blackColor.withOpacity(0.6),
          ),
    );
  }

  Widget _buildAddress(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16.w, color: AppColor.violetColor),
        Gap(4.w),
        Expanded(
          child: Text(
            store.address,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.blackColor.withOpacity(0.8),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Row(
      children: [
        // Rating
        Icon(Icons.star, size: 16.w, color: Colors.amber),
        Gap(4.w),
        Text(
          '${store.totalRating}/5',
          style: AppTextStyle(context).bodyTextSmall,
        ),
        Gap(12.w),
        // Status
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: store.status ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            store.status ? 'Mở cửa' : 'Đóng cửa',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: store.status ? Colors.green : Colors.red,
                  fontSize: 12.sp,
                ),
          ),
        ),
      ],
    );
  }
}

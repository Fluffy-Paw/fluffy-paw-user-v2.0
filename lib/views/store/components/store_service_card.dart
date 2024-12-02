import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/layouts/service_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class StoreServiceCard extends StatelessWidget {
  final StoreServiceModel service;

  const StoreServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailLayout(
                service: service,
                
               // storeId: storeId,
              ),
            ),
          );
          },
          child: SizedBox(
            height: 124.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceImage(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildServiceName(context),
                            Gap(4.h),
                            _buildBrandInfo(context),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildServiceStats(context),
                            Gap(4.h),
                            _buildPrice(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage() {
    return Container(
      width: 124.w,
      height: 124.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          bottomLeft: Radius.circular(16.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          bottomLeft: Radius.circular(16.r),
        ),
        child: CachedNetworkImage(
          imageUrl: service.image,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: Center(
              child: Icon(
                Icons.pets,
                size: 32.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[100],
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: 32.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceName(BuildContext context) {
    return Text(
      service.name,
      style: AppTextStyle(context).subTitle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBrandInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.store_outlined,
          size: 14.sp,
          color: AppColor.greyColor,
        ),
        Gap(4.w),
        Expanded(
          child: Text(
            service.brandName ?? "Thương hiệu không xác định",
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: AppColor.violetColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceStats(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          size: 14.sp,
          color: AppColor.amber500,
        ),
        Gap(2.w),
        Text(
          service.totalRating.toString(),
          style: AppTextStyle(context).bodyTextSmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap(8.w),
        Expanded(
          child: Text(
            'Đã bán ${service.bookingCount}',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: AppColor.greyColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'đ',
        decimalDigits: 0,
      ).format(service.cost),
      style: AppTextStyle(context).bodyText.copyWith(
        color: AppColor.violetColor,
        fontWeight: FontWeight.w700,
        fontSize: 15.sp,
      ),
    );
  }
}
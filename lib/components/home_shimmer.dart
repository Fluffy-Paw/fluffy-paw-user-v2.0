import 'package:fluffypawuser/config/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.whiteColor,
      highlightColor: AppColor.offWhiteColor,
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ).copyWith(top: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shimmerTop(),
              SizedBox(
                height: 55.h,
              ),
              shimmerBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20.h,
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.offWhiteColor,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          height: 14.h,
          width: 260.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.offWhiteColor,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 14.h,
          width: 220.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.offWhiteColor,
          ),
        ),
      ],
    );
  }

  Widget shimmerBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.offWhiteColor,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.offWhiteColor,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 260.h,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.offWhiteColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.offWhiteColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.offWhiteColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.offWhiteColor,
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

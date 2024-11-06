import 'package:fluffypawuser/config/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class EarningHistoryShimmerWidget extends StatelessWidget {
  const EarningHistoryShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.whiteColor,
      highlightColor: AppColor.offWhiteColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        itemCount: 10,
        itemBuilder: ((context, index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              height: 80.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.offWhiteColor,
                borderRadius: BorderRadius.circular(8),
              ),
            )),
      ),
    );
  }
}
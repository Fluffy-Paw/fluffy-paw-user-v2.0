import 'dart:ui';

import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReportSuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const ReportSuccessScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColor.violetColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 64.sp,
                    color: AppColor.violetColor,
                  ),
                ),
                Gap(24.h),
                Text(
                  'Báo cáo thành công',
                  style: AppTextStyle(context).title.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.violetColor,
                  ),
                ),
                Gap(12.h),
                Text(
                  'Cảm ơn bạn đã gửi báo cáo. Chúng tôi sẽ xem xét và phản hồi sớm nhất có thể.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle(context).bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Gap(32.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.violetColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
                      style: AppTextStyle(context).buttonText.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
}
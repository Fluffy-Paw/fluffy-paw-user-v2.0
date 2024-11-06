import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyle {
  final BuildContext context;
  AppTextStyle(this.context);

  TextStyle get title => TextStyle(
        color: colors(context).headingColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
      );
  TextStyle get subTitle => TextStyle(
        color: colors(context).headingColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      );
  TextStyle get bodyText => TextStyle(
        color: colors(context).bodyTextColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w300,
      );
  TextStyle get bodyTextSmall => TextStyle(
        color: colors(context).bodyTextColor!.withOpacity(0.5),
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      );
  TextStyle get buttonText => TextStyle(
        color: AppColor.whiteColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w300,
      );
  TextStyle get hintText => TextStyle(
        color: colors(context).hintTextColor,
        fontSize: 21.sp,
        fontWeight: FontWeight.w300,
      );
  TextStyle get appBarText => TextStyle(
        color: colors(context).headingColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );
}

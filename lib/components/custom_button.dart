import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final void Function()? onPressed;

  const CustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            buttonColor ?? colors(context).primaryColor),
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, 50.h),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: AppTextStyle(context).bodyText.copyWith(
              color: AppColor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

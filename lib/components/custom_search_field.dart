import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchField extends StatelessWidget {
  final String name;
  final FocusNode? focusNode;
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController controller;
  final Widget? widget;
  final void Function(String?)? onChanged;
  const CustomSearchField({
    Key? key,
    required this.name,
    this.focusNode,
    required this.hintText,
    required this.textInputType,
    required this.controller,
    required this.widget,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      textAlign: TextAlign.start,
      name: name,
      focusNode: focusNode,
      controller: controller,
      style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColor.blackColor,
          ),
      cursorColor: colors(context).primaryColor,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14),
        alignLabelWithHint: true,
        labelText: hintText,
        labelStyle: AppTextStyle(context).bodyTextSmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor.withOpacity(0.5),
            ),
        suffixIcon: widget,
        floatingLabelStyle: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w400,
              color: colors(context).primaryColor,
            ),
        filled: true,
        fillColor: AppColor.whiteColor,
        errorStyle: AppTextStyle(context).bodyTextSmall.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColor.redColor,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(
            color: AppColor.offWhiteColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: AppColor.offWhiteColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
              color: colors(context).primaryColor ?? AppColor.violetColor,
              width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      onChanged: onChanged,
      keyboardType: textInputType,
    );
  }
}

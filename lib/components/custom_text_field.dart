import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String name;
  final FocusNode? focusNode;
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final Widget? widget;
  final bool? obscureText;
  final int? minLines;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;  // Add this line

  const CustomTextFormField({
    Key? key,
    required this.name,
    this.focusNode,
    required this.hintText,
    required this.textInputType,
    required this.controller,
    required this.textInputAction,
    required this.validator,
    this.readOnly,
    this.widget,
    this.obscureText,
    this.minLines,
    this.enabled,
    this.inputFormatters,  // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: readOnly ?? false,
      child: FormBuilderTextField(
        enabled: enabled ?? true,
        readOnly: readOnly ?? false,
        textAlign: TextAlign.start,
        minLines: minLines ?? 1,
        maxLines: minLines ?? 1,
        name: name,
        focusNode: focusNode,
        controller: controller,
        obscureText: obscureText ?? false,
        inputFormatters: inputFormatters,  // Add this line
        style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor,
            ),
        cursorColor: colors(context).primaryColor,
        decoration: InputDecoration(
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
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(
              color: AppColor.offWhiteColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide:
                const BorderSide(color: AppColor.offWhiteColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: colors(context).primaryColor ?? AppColor.violetColor,
                width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        keyboardType: textInputType,
        textInputAction: textInputAction,
        validator: validator,
      ),
    );
  }
}
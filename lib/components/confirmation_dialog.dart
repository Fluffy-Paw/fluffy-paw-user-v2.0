import 'package:fluffypawuser/components/custom_button.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ConfirmationDialog extends StatelessWidget {
  final String text;
  final bool isLoading;
  final void Function()? cancelTapAction;
  final void Function()? applyTapAction;
  final Image image;
  const ConfirmationDialog({
    Key? key,
    required this.isLoading,
    required this.text,
    this.cancelTapAction,
    this.applyTapAction,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.whiteColor,
      surfaceTintColor: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(10.h),
            image,
            Gap(16.h),
            Text(
              text,
              style: AppTextStyle(context).subTitle,
              textAlign: TextAlign.center,
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Material(
                      color: AppColor.offWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50.r),
                        onTap: cancelTapAction,
                        child: SizedBox(
                          height: 50.h,
                          child: Center(
                            child: Text(
                              S.of(context).cancel,
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.blackColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(20.w),
                  Flexible(
                    flex: 1,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            buttonText: S.of(context).apply,
                            onPressed: applyTapAction),
                  ),
                ],
              ),
            ),
            Gap(20.h)
          ],
        ),
      ),
    );
  }
}

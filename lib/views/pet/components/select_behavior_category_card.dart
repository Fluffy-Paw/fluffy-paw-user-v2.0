import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SelectBehaviorCategoryCard extends ConsumerWidget {
  final BehaviorCategory behaviorCategory;

  const SelectBehaviorCategoryCard({
    Key? key,
    required this.behaviorCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        children: [
          ListTile(
            onTap: () {
              ref.read(selectedBehaviorCategory.notifier).state = 
                  behaviorCategory.id;
            },
            contentPadding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 18.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: const BorderSide(
                color: AppColor.offWhiteColor,
              ),
            ),
            // leading: CircleAvatar(
            //   backgroundColor: AppColor.violetColor,
            //   radius: 26,
            //   backgroundImage: CachedNetworkImageProvider(
            //     behaviorCategory.image,
            //     errorListener: (e) {
            //       debugPrint(e.toString());
            //     },
            //   ),
            // ),
            title: Text(
              behaviorCategory.name,
              style: AppTextStyle(context)
                  .subTitle
                  .copyWith(fontSize: 16, color: AppColor.blackColor),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Row(
                children: [
                  Text(
                    behaviorCategory.name,
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColor.blackColor.withOpacity(0.7),
                        ),
                  ),
                  Gap(5.w),
                  CircleAvatar(
                    radius: 3,
                    backgroundColor: AppColor.blackColor.withOpacity(0.2),
                  ),
                  Gap(5.w),
                  Container(
                    height: 20.h,
                    constraints: BoxConstraints(minWidth: 20.w),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColor.blackColor,
                    ),
                    child: Center(
                      child: Text(
                        behaviorCategory.id.toString(),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.whiteColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: AppColor.blackColor.withOpacity(0.2),
              ),
              child: Radio(
                activeColor: colors(context).primaryColor,
                value: behaviorCategory.id,
                groupValue: ref.watch(selectedBehaviorCategory) ?? '',
                onChanged: (v) {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class AppBottomNavbar extends ConsumerWidget {
  const AppBottomNavbar({
    super.key,
    required this.bottomItem,
    required this.onSelect,
  });
  final List<BottomItem> bottomItem;
  final Function(int? index) onSelect;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      height: 85.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          if (Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor)
            const BoxShadow(
              color: AppColor.offWhiteColor,
              spreadRadius: -2,
              blurRadius: 5,
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          bottomItem.length,
              (index) {
            return GestureDetector(
              onTap: () {
                onSelect(index);
              },
              child: _buildBottomItem(
                bottomItem: bottomItem[index],
                index: index,
                context: context,
                ref: ref,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomItem(
      {required BottomItem bottomItem,
        required int index,
        required BuildContext context,
        required WidgetRef ref}) {
    final int selectedIndex = ref.watch(selectedIndexProvider);
    return SizedBox(
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Center(
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 200),
                  height: index == selectedIndex ? 40.0 : 0.0,
                  width: index == selectedIndex ? 40.0 : 0.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: index == selectedIndex
                        ? colors(context).primaryColor
                        : Colors.transparent,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.zero,
                height: 42.h,
                width: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    index == selectedIndex
                        ? bottomItem.activeIcon
                        : bottomItem.icon,
                    height: 26.h,
                    width: 26.w,
                  ),
                ),
              )
            ],
          ),
          Gap(3.h),
          Text(
            bottomItem.name,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: index == selectedIndex
                    ? colors(context).primaryColor
                    : colors(context).bodyTextSmallColor),
          )
        ],
      ),
    );
  }
}
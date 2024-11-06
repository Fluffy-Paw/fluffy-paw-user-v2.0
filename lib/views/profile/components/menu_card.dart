import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.context,
    required this.icon,
    required this.text,
    required this.onTap,
    this.type,
  });

  final BuildContext context;
  final String icon;
  final String text;
  final void Function() onTap;
  final String? type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.whiteColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            children: [
              // Left section with icon and text
              Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      icon,
                      width: 24.w, // Fixed width for consistency
                    ),
                    Gap(10.w),
                    Flexible(
                      child: Text(
                        text,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Right section with different widgets based on type
              if (type == null) ...[
                Icon(
                  Icons.chevron_right,
                  color: AppColor.blackColor.withOpacity(0.5),
                )
              ] else if (type == 'launguage') ...[
                ValueListenableBuilder(
                  valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
                  builder: (context, appSettings, _) {
                    final storedLanguage = appSettings.get(AppConstants.appLocal);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(storedLanguage['name']),
                        Icon(
                          Icons.chevron_right,
                          color: AppColor.blackColor.withOpacity(0.5),
                        )
                      ],
                    );
                  }
                )
              ] else if (type == 'theme') ...[
                ValueListenableBuilder(
                  valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
                  builder: (context, box, _) {
                    final isDarkTheme = box.get(AppConstants.isDarkTheme);
                    return SizedBox(
                      height: 45.h,
                      child: LiteRollingSwitch(
                        width: 110.w,
                        colorOff: AppColor.violetColor,
                        animationDuration: const Duration(milliseconds: 500),
                        textOnColor: colors(context).accentColor ?? AppColor.offWhiteColor,
                        textOffColor: AppColor.whiteColor,
                        value: isDarkTheme ?? false,
                        textOn: 'Dark',
                        textOff: 'Light',
                        colorOn: AppColor.blackColor,
                        iconOn: Icons.dark_mode,
                        iconOff: Icons.dark_mode,
                        textSize: 16.0,
                        onTap: () {},
                        onDoubleTap: () {},
                        onSwipe: () {},
                        onChanged: (bool isDark) {
                          box.put(AppConstants.isDarkTheme, isDark);
                        },
                      ),
                    );
                  },
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
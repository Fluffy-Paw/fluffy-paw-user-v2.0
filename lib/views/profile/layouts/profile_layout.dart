import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/components/confirmation_dialog.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/utils/global_function.dart';
import 'package:fluffypawuser/views/profile/components/language.dart';
import 'package:fluffypawuser/views/profile/components/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ProfileLayout extends ConsumerStatefulWidget {
  const ProfileLayout({super.key});

  @override
  ConsumerState<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends ConsumerState<ProfileLayout> {
  String earningThisMonth = '';

  Future<void> _handleLogout() async {
    try {
      await ref.read(hiveStoreService).removeAllData();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        GlobalFunction.showCustomSnackbar(
          message: 'Error during logout: $e',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWidget(),
            Gap(14.h),
            _buildBodyWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget() {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppConstants.userBox).listenable(),
      builder: (context, userBox, _) {
        final userInfo = userBox.get(AppConstants.userData);
        if (userInfo == null) {
          return SizedBox(height: 200.h); // Placeholder height
        }

        UserModel? user;
        try {
          Map<String, dynamic> userInfoStringKeys = Map<String, dynamic>.from(userInfo);
          user = UserModel.fromMap(userInfoStringKeys);
        } catch (e) {
          debugPrint('Error parsing user data: $e');
          return SizedBox(height: 200.h);
        }

        return Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w)
                  .copyWith(top: 60.h, bottom: 14.h),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 40.sp,
                        backgroundImage: CachedNetworkImageProvider(
                          user.avatar,
                          errorListener: (error) => debugPrint('Error loading avatar: $error'),
                        ),
                        onBackgroundImageError: (exception, stackTrace) {
                          debugPrint('Error loading avatar: $exception');
                        },
                      ),
                      Positioned(
                        right: -10,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 16.sp,
                          backgroundColor: Colors.white,
                          child: SvgPicture.asset(
                            Assets.svg.fluffyPawDarl,
                            width: 24.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                  Gap(14.h),
                  Row(
                    children: [
                      Text(
                        "${user.username} Pet Owner",
                        style: AppTextStyle(context).title,
                      ),
                      Gap(10.w),
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: colors(context).bodyTextSmallColor!.withOpacity(0.2),
                      ),
                      Gap(10.w),
                      Text(
                        user.phone,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  Gap(10.h),
                  Text(
                    user.email,
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                  Gap(14.h),
                  _buildFluffyCoinCard(),
                ],
              ),
            ),
            Positioned(
              top: 70.h,
              right: 20.w,
              child: FlutterSwitch(
                width: 80.w,
                activeText: S.of(context).open,
                inactiveText: S.of(context).close,
                valueFontSize: 14,
                activeTextColor: AppColor.whiteColor,
                activeColor: AppColor.violetColor,
                inactiveTextFontWeight: FontWeight.w400,
                activeTextFontWeight: FontWeight.w400,
                showOnOff: true,
                value: true,
                onToggle: (v) {},
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildFluffyCoinCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors(context).primaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                Assets.svg.doller,
                color: AppColor.whiteColor,
                height: 30.h,
              ),
              Gap(10.w),
              Text(
                S.of(context).fluffyCoin,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
          ref.watch(profileController)
              ? Shimmer.fromColors(
                  baseColor: AppColor.whiteColor,
                  highlightColor: AppColor.blackColor,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColor.offWhiteColor.withOpacity(0.2),
                    ),
                    child: Text(
                      '0.00',
                      style: AppTextStyle(context).title.copyWith(
                        color: AppColor.whiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                )
              : Text(
                  '${AppConstants.appCurrency}${GlobalFunction.numberLocalization(earningThisMonth)}',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildBodyWidget() {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildMenuSection(),
            Gap(14.h),
            _buildLanguageSection(),
            Gap(14.h),
            _buildSettingsSection(),
            Gap(14.h),
            _buildLogoutButton(),
            Gap(50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: AppColor.whiteColor,
      child: Column(
        children: [
          MenuCard(
            context: context,
            icon: Assets.svg.pet,
            text: S.of(context).pet,
            onTap: () {
              ref.read(petController.notifier).getPetList();
              context.nav.pushNamed(Routes.petList);
            },
          ),
          _buildDivider(),
          MenuCard(
            context: context,
            icon: Assets.svg.userProfile,
            text: S.of(context).account,
            onTap: () => context.nav.pushNamed(Routes.profile),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      color: AppColor.whiteColor,
      child: Column(
        children: [
          MenuCard(
            context: context,
            icon: Assets.svg.language,
            text: S.of(context).language,
            type: 'language',
            onTap: () => _showLanguageBottomSheet(),
          ),
          _buildDivider(),
          MenuCard(
            context: context,
            icon: Assets.svg.sun,
            text: S.of(context).theme,
            type: 'theme',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      color: AppColor.whiteColor,
      child: Column(
        children: [
          MenuCard(
            context: context,
            icon: Assets.svg.sellerSupport,
            text: S.of(context).support,
            onTap: () {},
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MenuCard(
      context: context,
      icon: Assets.svg.logout,
      text: S.of(context).logout,
      type: 'logout',
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => ConfirmationDialog(
            isLoading: false,
            text: S.of(context).logoutDes,
            cancelTapAction: () => Navigator.pop(dialogContext),
            applyTapAction: () {
              Navigator.pop(dialogContext);
              _handleLogout();
            },
            image: Assets.image.question.image(width: 80.w),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 0,
      thickness: 0.5,
      indent: 20,
      endIndent: 20,
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      context: context,
      builder: (BuildContext context) => ShowLanguage(),
    );
  }
}
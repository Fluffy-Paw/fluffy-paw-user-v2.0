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
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref
    //       .read(profileController.notifier)
    //       .getEarningHistory(
    //         type: ref.read(selectedDateFilter),
    //         date: ref.read(selectedDate),
    //         paymentMethod: null,
    //         pagination: false,
    //         page: 1,
    //         perPage: 20,
    //       )
    //       .then((value) {
    //     setState(() {
    //       earningThisMonth = ref
    //           .read(profileController.notifier)
    //           .earningHistory
    //           .thisMonthEarnings;
    //     });
    //   });
    // });

    super.initState();
  }

  bool isLoading = true;
  String earningThisMonth = '';
  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWidget(context: context, ref: ref),
            Gap(14.h),
            _buildBodyWidget(context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget(
      {required BuildContext context, required WidgetRef ref}) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppConstants.userBox).listenable(),
        builder: (context, userBox, _) {
          Map<dynamic, dynamic>? userInfo = userBox.get(AppConstants.userData);
          Map<String, dynamic> userInfoStringKeys =
              userInfo!.cast<String, dynamic>();
          UserModel user = UserModel.fromMap(userInfoStringKeys);
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
                          backgroundImage:
                              CachedNetworkImageProvider(user.avatar),
                        ),
                        Positioned(
                          right: -10,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16.sp,
                            backgroundImage: CachedNetworkImageProvider(
                                Assets.svg.fluffyPawDarl),
                          ),
                        )
                      ],
                    ),
                    Gap(14.h),
                    Row(
                      children: [
                        Text(
                          "${user.username} ${"Pet Owner"}",
                          style: AppTextStyle(context).title,
                        ),
                        Gap(10.w),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: colors(context)
                              .bodyTextSmallColor!
                              .withOpacity(0.2),
                        ),
                        Gap(10.w),
                        Text(
                          user.phone,
                          style: AppTextStyle(context)
                              .bodyTextSmall
                              .copyWith(fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Gap(10.h),
                    Text(
                      user.email,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(),
                    ),
                    Gap(14.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: colors(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Assets.svg.doller,
                                  color: AppColor.whiteColor,
                                  height: 30.h,
                                ),
                                Gap(10.w),
                                Text(
                                  S.of(context).fluffyCoin,
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(
                                        color: AppColor.whiteColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                )
                              ],
                            ),
                          ),
                          ref.watch(profileController)
                              ? Shimmer.fromColors(
                                  baseColor: AppColor.whiteColor,
                                  highlightColor: AppColor.blackColor,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColor.offWhiteColor
                                          .withOpacity(0.2),
                                    ),
                                    child: Text(
                                      '0.00',
                                      style: AppTextStyle(context)
                                          .title
                                          .copyWith(
                                              color: AppColor.whiteColor,
                                              fontSize: 16.sp),
                                    ),
                                  ),
                                )
                              : Text(
                                  '${AppConstants.appCurrency}${GlobalFunction.numberLocalization(earningThisMonth)}',
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(
                                        color: AppColor.whiteColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                )
                        ],
                      ),
                    )
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
                  //value: ref.watch(shopStatus),
                  value: true,
                  onToggle: (v) {
                    //ref.read(shopStatus.notifier).state = v;
                  },
                ),
              )
            ],
          );
        });
  }

  Widget _buildBodyWidget({required BuildContext context}) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            // seller part
            Container(
              color: AppColor.whiteColor,
              child: Column(
                children: [
                  MenuCard(
                    context: context,
                    icon: Assets.svg.pet,
                    text: S.of(context).pet,
                    onTap: () {
                      // Refresh pet list khi vào trang
                      ref.read(petController.notifier).getPetList();
                      // Điều hướng đến trang pet list
                      context.nav.pushNamed(Routes.petList);
                    },
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuCard(
                    context: context,
                    icon: Assets.svg.userProfile,
                    text: S.of(context).account,
                    onTap: () {
                      //context.nav.pushNamed(Routes.sellerAccount);
                    },
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  // MenuCard(
                  //   context: context,
                  //   icon: Assets.svg.storeAccount,
                  //   text: S.of(context).staffmanageservice,
                  //   onTap: () {
                  //     //context.nav.pushNamed(Routes.storeAccount);
                  //   },
                  // ),
                ],
              ),
            ),
            Gap(14.h),
            // language
            Container(
              color: AppColor.whiteColor,
              child: Column(
                children: [
                  MenuCard(
                    context: context,
                    icon: Assets.svg.language,
                    text: S.of(context).language,
                    type: 'launguage',
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: true,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          return ShowLanguage();
                        },
                      );
                    },
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  MenuCard(
                    context: context,
                    icon: Assets.svg.sun,
                    text: S.of(context).theme,
                    type: 'theme',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Gap(14.h),
            // settings part
            Container(
              color: AppColor.whiteColor,
              child: Column(
                children: [
                  MenuCard(
                    context: context,
                    icon: Assets.svg.sellerSupport,
                    text: S.of(context).support,
                    onTap: () {
                      //context.nav.pushNamed(Routes.sellerSupportView);
                    },
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  // MenuCard(
                  //   context: context,
                  //   icon: Assets.svg.termsConditions,
                  //   text: S.of(context).termsconditions,
                  //   onTap: () {
                  //     //context.nav.pushNamed(Routes.termsAndconditionsView);
                  //   },
                  // ),
                  // const Divider(
                  //   height: 0,
                  //   thickness: 0.5,
                  //   indent: 20,
                  //   endIndent: 20,
                  // ),
                  // MenuCard(
                  //   context: context,
                  //   icon: Assets.svg.privacy,
                  //   text: S.of(context).privacyPolicy,
                  //   onTap: () {
                  //     //context.nav.pushNamed(Routes.privacyPolicyView);
                  //   },
                  // ),
                ],
              ),
            ),
            Gap(14.h),
            // logout
            Consumer(builder: (context, ref, _) {
              return MenuCard(
                context: context,
                icon: Assets.svg.logout,
                text: S.of(context).logout,
                type: 'logout',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      isLoading: false,
                      text: S.of(context).logoutDes,
                      cancelTapAction: () {
                        context.nav.pop(context);
                      },
                      applyTapAction: () {
                        ref
                            .read(hiveStoreService)
                            .removeAllData()
                            .then((isSuccess) {
                          if (isSuccess) {
                            ref.refresh(selectedIndexProvider.notifier).state;
                            context.nav.pushNamedAndRemoveUntil(
                                Routes.login, (route) => false);
                          } else {
                            context.nav.pop();
                            GlobalFunction.showCustomSnackbar(
                              message: 'Somthing went wrong!',
                              isSuccess: false,
                            );
                          }
                        });
                      },
                      image: Assets.image.question.image(width: 80.w),
                    ),
                  );
                },
              );
            }),
            Gap(50.h),
          ],
        ),
      ),
    );
  }

  final String profileImage =
      "https://as2.ftcdn.net/v2/jpg/03/64/21/11/1000_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg";

  final String shopLogo =
      "https://i.pinimg.com/originals/0d/cf/b5/0dcfb548989afdf22afff75e2a46a508.jpg";
}

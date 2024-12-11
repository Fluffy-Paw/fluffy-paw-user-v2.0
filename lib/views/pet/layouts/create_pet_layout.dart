import 'dart:io';

import 'package:fluffypawuser/components/custom_button.dart';
import 'package:fluffypawuser/components/custom_text_field.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:fluffypawuser/models/pet/pet_request.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/utils/global_function.dart';
import 'package:fluffypawuser/views/authentication/components/gender_menu.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:fluffypawuser/views/pet/layouts/behavior_cateogry_select_layout.dart';
import 'package:fluffypawuser/views/pet/layouts/pet_type_select_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CreatePetLayout extends ConsumerStatefulWidget {
  final int petType;
  const CreatePetLayout({super.key, required this.petType});

  @override
  ConsumerState<CreatePetLayout> createState() => _CreatePetLayoutState();
}

class _CreatePetLayoutState extends ConsumerState<CreatePetLayout> {
  final List<FocusNode> fNodeList = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  int? selectedPet;
  dynamic selectedBehavior;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị petType từ tham số widget
    setState(() {
      selectedPet = widget.petType;
    });
    ref.read(isNeuterProvider).text = 'false';
    GlobalFunction.clearControllers(ref: ref);

  }

  @override
  void dispose() {
    for (var node in fNodeList) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColor.offWhiteColor : AppColor.offWhiteColor,
        appBar: AppBar(
          title: Text(S.of(context).addPet),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar:
            _buildBottomWidget(isDark: isDark, context: context, ref: ref),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(3),
              _buildHeaderWidget(context: context, ref: ref, isDark: isDark),
              Gap(10.h),
              _buildFormWidget(context: context, ref: ref, isDark: isDark)
            ],
          ),
        ),
      ),
    );
  }

  Container _buildBottomWidget(
      {required bool isDark,
      required BuildContext context,
      required WidgetRef ref}) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        border: Border(
          top: BorderSide(
              color: colors(context).bodyTextSmallColor!.withOpacity(0.1),
              width: 2),
        ),
      ),
      child: Center(
        child: ref.watch(petController)
            ? const CircularProgressIndicator()
            : SizedBox(
                height: 50.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomButton(
                    buttonText: S.of(context).createNewPet,
                    buttonColor: colors(context).primaryColor,
                    onPressed: () {
                      if (ref.read(selectedUserProfileImage) != null) {
                        if (ref.read(ridersFormKey).currentState!.validate()) {
                          final PetRequest petInfo = PetRequest(
                              name: ref.read(firstNameProvider).text,
                              description: ref.read(descriptionProvider).text,
                              sex: ref.read(genderProvider).text,
                              allergy: ref.read(allergyProvider).text,
                              behaviorCategoryId: int.parse(
                                  ref.read(behaviorCategoryProvider).text),
                              isNeuter: ref
                                      .read(isNeuterProvider)
                                      .text
                                      .toLowerCase() ==
                                  'true',
                              petTypeId:
                                  int.parse(ref.read(petTypeProvider).text),
                              dob: DateFormat('yyyy-MM-dd').format(
                                DateFormat('MM/dd/yyyy')
                                    .parse(ref.read(dateOfBirthProvider).text),
                              ),
                              weight: double.parse(ref
                                  .read(weightProvider)
                                  .text), // Chuyển đổi thành double
                              microchipNumber:
                                  ref.read(microchipNumberProvider).text);

                          ref
                              .read(petController.notifier)
                              .addPet(
                                petRequest: petInfo,
                                profile: File(
                                    ref.read(selectedUserProfileImage)!.path),
                              )
                              .then((response) {
                            if (response.isSuccess) {
                              GlobalFunction.showCustomSnackbar(
                                message: response.message,
                                isSuccess: true,
                              );
                              GlobalFunction.clearControllers(ref: ref);
                              ref.read(petController.notifier).getPetList();
                              ref.read(selectedIndexProvider.notifier).state =
                                  0;

                              // Navigate to bottom navigation layout and remove all previous routes
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavigationLayout(),
                                ),
                                (route) => false,
                              );
                            }
                          });
                          // debugPrint(riderInfo.toJson());
                        }
                      } else {
                        GlobalFunction.showCustomSnackbar(
                          message: S.of(context).profileImageIsReq,
                          isSuccess: false,
                        );
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderWidget({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
  }) {
    return Container(
      color: isDark ? AppColor.blackColor : AppColor.whiteColor,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 30.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90.h,
            width: 90.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: ref.watch(selectedUserProfileImage) != null
                  ? CircleAvatar(
                      radius: 90.r,
                      backgroundImage: FileImage(
                        File(ref
                            .watch(selectedUserProfileImage.notifier)
                            .state!
                            .path),
                      ),
                    )
                  : Assets.image.avatar.image(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).addPetPhotoReq,
                  style: AppTextStyle(context).title,
                ),
                Gap(12.h),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        GlobalFunction.pickImageFromCamera(ref: ref);
                      },
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors(context).primaryColor ??
                                AppColor.violetColor,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.photo_camera,
                            color: colors(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    InkWell(
                      onTap: () {
                        GlobalFunction.pickImageFromGallery(
                            ref: ref, imageType: ImageType.userProfile);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                colors(context).bodyTextColor!.withOpacity(0.5),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: colors(context).bodyTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormWidget(
      {required BuildContext context,
      required WidgetRef ref,
      required bool isDark}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: FormBuilder(
          key: ref.read(ridersFormKey),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: CustomTextFormField(
                            name: 'firstName',
                            focusNode: fNodeList[0],
                            hintText: S.of(context).pet,
                            textInputType: TextInputType.text,
                            controller: ref.watch(firstNameProvider),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                GlobalFunction.firstNameValidator(
                              value: value!,
                              hintText: S.of(context).petName,
                              context: context,
                            ),
                          ),
                        ),
                        Gap(16.w),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetTypeSelectLayout(
                                    pettype: selectedPet ?? 0,
                                  ),
                                ),
                              );

                              // Cập nhật khi có kết quả trả về
                              if (result != null && result is PetType) {
                                setState(() {
                                  selectedPet = result.id;
                                  // Cập nhật provider nếu cần
                                  ref.read(petTypeProvider).text =
                                      result.id.toString();
                                });
                              }
                            },
                            child: CustomTextFormField(
                              key: Key('petType'),
                              name: 'petType',
                              enabled: false,
                              hintText: 'Chọn loại thú cưng',
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              controller: TextEditingController(
                                text: selectedPet == null
                                    ? ''
                                    : ref
                                            .read(petController.notifier)
                                            .petTypes
                                            ?.firstWhere((type) =>
                                                type.id == selectedPet)
                                            .name ??
                                        '',
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (selectedPet == null) {
                                  return 'Vui lòng chọn loại thú cưng';
                                }
                                return null;
                              },
                              widget: Icon(
                                Icons.keyboard_arrow_down,
                                size: 35.sp,
                                color: AppColor.blackColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(20.h),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BehaviorCategorySelectLayout(),
                          ),
                        );

                        // Cập nhật giá trị khi có kết quả trả về
                        if (result != null && result is BehaviorCategory) {
                          setState(() {
                            selectedBehavior = result;
                            // Cập nhật id vào provider
                            ref.read(behaviorCategoryProvider).text =
                                result.id.toString();
                          });
                        }
                      },
                      child: CustomTextFormField(
                        name: 'behavior',
                        focusNode: fNodeList[2],
                        hintText: 'Chọn hành vi thú cưng',
                        textInputType: TextInputType.text,
                        // Hiển thị name cho người dùng thấy
                        controller: TextEditingController(
                          text: selectedBehavior?.name ?? '',
                        ),
                        textInputAction: TextInputAction.next,
                        readOnly: true,
                        // Sửa lại validator để kiểm tra selectedBehavior thay vì value
                        validator: (value) {
                          if (selectedBehavior == null) {
                            return 'Vui lòng chọn hành vi thú cưng';
                          }
                          return null;
                        },
                        widget: Icon(
                          Icons.keyboard_arrow_down,
                          size: 35.sp,
                          color: AppColor.blackColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Gap(20.w),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                isDismissible: false,
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
                                  return ShowGenderMenu();
                                },
                              );
                            },
                            child: CustomTextFormField(
                              name: 'gender',
                              focusNode: fNodeList[4],
                              hintText: S.of(context).gender,
                              textInputType: TextInputType.text,
                              controller: ref.read(genderProvider),
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              widget: Icon(
                                Icons.keyboard_arrow_down,
                                size: 35.sp,
                                color: AppColor.blackColor.withOpacity(0.6),
                              ),
                              validator: (value) =>
                                  GlobalFunction.defaultValidator(
                                value: value!,
                                hintText: S.of(context).gender,
                                context: context,
                              ),
                            ),
                          ),
                        ),
                        Gap(16.w),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => GlobalFunction.datePicker(
                                context: context, ref: ref),
                            child: CustomTextFormField(
                              name: 'dateOfBirth',
                              focusNode: fNodeList[5],
                              hintText: S.of(context).dateOfBirth,
                              textInputType: TextInputType.text,
                              controller: ref.watch(dateOfBirthProvider),
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              widget: Icon(
                                Icons.calendar_month,
                                size: 24.sp,
                                color: AppColor.blackColor.withOpacity(0.6),
                              ),
                              validator: (value) =>
                                  GlobalFunction.dateOfBirthValidator(
                                value: value!,
                                hintText: S.of(context).dateOfBirth,
                                context: context,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(20.w),
                    CustomTextFormField(
                      name: 'weight',
                      focusNode: fNodeList[3],
                      hintText: S.of(context).weight,
                      textInputType: TextInputType.text,
                      controller: ref.watch(weightProvider),
                      textInputAction: TextInputAction.next,
                      validator: (value) => GlobalFunction.weightValidator(
                        value: value!,
                        hintText: S.of(context).weight,
                        context: context,
                      ),
                    ),
                    Gap(20.w),
                    CustomTextFormField(
                      name: 'allergy',
                      focusNode: fNodeList[7],
                      hintText: S.of(context).allergy,
                      textInputType: TextInputType.text,
                      controller: ref.watch(allergyProvider),
                      textInputAction: TextInputAction.done,
                      validator: (value) => GlobalFunction.defaultValidator(
                        value: value!,
                        hintText: S.of(context).allergy,
                        context: context,
                      ),
                    ),
                    Gap(20.w),
                    CustomTextFormField(
                      name: 'microchip',
                      focusNode: fNodeList[8],
                      hintText: S.of(context).microchip,
                      textInputType: TextInputType.text,
                      controller: ref.watch(microchipNumberProvider),
                      textInputAction: TextInputAction.done,
                      validator: (value) => GlobalFunction.defaultValidator(
                        value: value!,
                        hintText: S.of(context).microchip,
                        context: context,
                      ),
                    ),
                    Gap(20.w),
                    CustomTextFormField(
                      name: 'description',
                      focusNode: fNodeList[9],
                      hintText: S.of(context).description,
                      textInputType: TextInputType.text,
                      controller: ref.watch(descriptionProvider),
                      textInputAction: TextInputAction.done,
                      validator: (value) => GlobalFunction.defaultValidator(
                        value: value!,
                        hintText: S.of(context).description,
                        context: context,
                      ),
                    ),
                    Gap(20.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã triệt sản',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColor.blackColor.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.whiteColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColor.offWhiteColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            ref.read(isNeuterProvider).text =
                                                'false';
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: ref
                                                        .watch(isNeuterProvider)
                                                        .text ==
                                                    'false'
                                                ? colors(context).primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8.r),
                                              bottomLeft: Radius.circular(8.r),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Chưa triệt sản',
                                              style: TextStyle(
                                                color: ref
                                                            .watch(
                                                                isNeuterProvider)
                                                            .text ==
                                                        'false'
                                                    ? Colors.white
                                                    : AppColor.blackColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 45.h,
                                      color: AppColor.offWhiteColor,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            ref.read(isNeuterProvider).text =
                                                'true';
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: ref
                                                        .watch(isNeuterProvider)
                                                        .text ==
                                                    'true'
                                                ? colors(context).primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8.r),
                                              bottomRight: Radius.circular(8.r),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Đã triệt sản',
                                              style: TextStyle(
                                                color: ref
                                                            .watch(
                                                                isNeuterProvider)
                                                            .text ==
                                                        'true'
                                                    ? Colors.white
                                                    : AppColor.blackColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

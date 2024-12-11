import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/components/custom_button.dart';
import 'package:fluffypawuser/components/custom_text_field.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:fluffypawuser/models/pet/pet_request.dart';
import 'package:fluffypawuser/utils/global_function.dart';
import 'package:fluffypawuser/views/authentication/components/gender_menu.dart';
import 'package:fluffypawuser/views/pet/layouts/behavior_cateogry_select_layout.dart';
import 'package:fluffypawuser/views/pet/layouts/pet_type_select_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdatePetLayout extends ConsumerStatefulWidget {
  final int petId;
  final PetDetail petDetail;

  const UpdatePetLayout({
    Key? key,
    required this.petId,
    required this.petDetail,
  }) : super(key: key);

  @override
  ConsumerState<UpdatePetLayout> createState() => _UpdatePetLayoutState();
}

class _UpdatePetLayoutState extends ConsumerState<UpdatePetLayout> {
  File? _selectedImage;
  final picker = ImagePicker();
  final List<FocusNode> fNodeList = List.generate(10, (_) => FocusNode());
  int? selectedPet;
  dynamic selectedBehavior;
  TextEditingController? _petTypeController;

  // Future<void> _pickImage(ImageSource source) async {
  //   final pickedFile = await picker.pickImage(source: source);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();
    _petTypeController =
        TextEditingController(text: widget.petDetail.petType.name);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(petController.notifier)
          .getPetType(widget.petDetail.petType.petCategoryId);
    });
    initializePetData();
  }

  void initializePetData() {
    ref.read(firstNameProvider).text = widget.petDetail.name;
    ref.read(descriptionProvider).text = widget.petDetail.decription;
    ref.read(genderProvider).text = widget.petDetail.sex;
    ref.read(allergyProvider).text = widget.petDetail.allergy;
    ref.read(behaviorCategoryProvider).text =
        widget.petDetail.behaviorCategory.id.toString();
    ref.read(isNeuterProvider).text = widget.petDetail.isNeuter.toString();
    ref.read(petTypeProvider).text = widget.petDetail.petType.id.toString();
    ref.read(dateOfBirthProvider).text =
        DateFormat('MM/dd/yyyy').format(DateTime.parse(widget.petDetail.dob));
    ref.read(weightProvider).text = widget.petDetail.weight.toString();
    ref.read(microchipNumberProvider).text = widget.petDetail.microchipNumber;

    setState(() {
      selectedPet = widget.petDetail.petType.id;
      selectedBehavior = BehaviorCategory(
        id: widget.petDetail.behaviorCategory.id,
        name: widget.petDetail.behaviorCategory.name ?? '',
      );
    });
  }

  @override
  void dispose() {
    _petTypeController?.dispose(); // Dispose controller khi không cần thiết
    for (var node in fNodeList) {
      node.dispose();
    }
    GlobalFunction.clearControllers(ref: ref);
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                //title: Text(S.of(context).),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                //title: Text(S.of(context).camera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
          title: Text(S.of(context).update),
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
              _buildFormWidget(context: context, ref: ref, isDark: isDark),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90.h,
            width: 90.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(45.r),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 90.h,
                          width: 90.w,
                          fit: BoxFit.cover,
                        )
                      : widget.petDetail.image != null
                          ? CachedNetworkImage(
                              imageUrl: widget.petDetail.image!,
                              height: 90.h,
                              width: 90.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.pets),
                            ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImageSourceSelection(context),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: colors(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update Photo",
                  style: AppTextStyle(context).title,
                ),
                Gap(8.h),
                Text(
                  "Change",
                  style: AppTextStyle(context).bodyTextSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormWidget({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
  }) {
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
                  // Pet Name and Type Selection
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: CustomTextFormField(
                          name: 'firstName',
                          focusNode: fNodeList[0],
                          hintText: S.of(context).petName,
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
                            if (context.mounted) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetTypeSelectLayout(
                                    pettype:
                                        widget.petDetail.petType.petCategoryId,
                                  ),
                                ),
                              );
                              if (result != null && result is PetType) {
                                setState(() {
                                  selectedPet = result.id;
                                  // Chỉ cập nhật controller và state
                                  ref.read(petTypeProvider).text =
                                      result.id.toString();
                                });

                                // Tạo một TextEditingController mới với tên mới
                                final petTypeController =
                                    TextEditingController(text: result.name);

                                // Cập nhật UI với controller mới
                                setState(() {
                                  _petTypeController = petTypeController;
                                });
                              }
                            }
                          },
                          child: CustomTextFormField(
                            name: 'petType',
                            enabled: false,
                            hintText: S.of(context).selectPetType,
                            textInputType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            // Sử dụng controller riêng cho petType
                            controller: _petTypeController ??
                                TextEditingController(
                                  text: widget.petDetail.petType.name,
                                ),
                            readOnly: true,
                            validator: (value) {
                              if (selectedPet == null) {
                                return S.of(context).selectPetType;
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

                  // Behavior Category Selection
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const BehaviorCategorySelectLayout(),
                        ),
                      );
                      if (result != null && result is BehaviorCategory) {
                        setState(() {
                          selectedBehavior = result;
                          ref.read(behaviorCategoryProvider).text =
                              result.id.toString();
                        });
                      }
                    },
                    child: CustomTextFormField(
                      name: 'behavior',
                      enabled: false,
                      hintText: S.of(context).select_behavior_category,
                      textInputType: TextInputType.text,
                      controller: TextEditingController(
                        text: selectedBehavior?.name ?? '',
                      ),
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      validator: (value) {
                        if (selectedBehavior == null) {
                          return S.of(context).select_behavior_category;
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
                  Gap(20.h),

                  // Gender and Date of Birth Selection
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
                            enabled: false,
                            hintText: S.of(context).gender,
                            textInputType: TextInputType.text,
                            controller: ref.watch(genderProvider),
                            textInputAction: TextInputAction.next,
                            readOnly: true,
                            validator: (value) =>
                                GlobalFunction.defaultValidator(
                              value: value!,
                              hintText: S.of(context).gender,
                              context: context,
                            ),
                            widget: Icon(
                              Icons.keyboard_arrow_down,
                              size: 35.sp,
                              color: AppColor.blackColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      Gap(16.w),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => GlobalFunction.datePicker(
                            context: context,
                            ref: ref,
                          ),
                          child: CustomTextFormField(
                            name: 'dateOfBirth',
                            enabled: false,
                            hintText: S.of(context).dateOfBirth,
                            textInputType: TextInputType.text,
                            controller: ref.watch(dateOfBirthProvider),
                            textInputAction: TextInputAction.next,
                            readOnly: true,
                            validator: (value) =>
                                GlobalFunction.dateOfBirthValidator(
                              value: value!,
                              hintText: S.of(context).dateOfBirth,
                              context: context,
                            ),
                            widget: Icon(
                              Icons.calendar_today,
                              size: 24.sp,
                              color: AppColor.blackColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(20.h),

                  // Weight Field
                  CustomTextFormField(
                    name: 'weight',
                    focusNode: fNodeList[3],
                    hintText: S.of(context).weight,
                    textInputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    controller: ref.watch(weightProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter weight';
                      }
                      try {
                        final double weight = double.parse(value!);
                        if (weight <= 0 || weight > 100) {
                          return 'Weight must be between 0 and 100kg';
                        }
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  Gap(20.h),

                  // Allergy Field
                  CustomTextFormField(
                    name: 'allergy',
                    focusNode: fNodeList[7],
                    hintText: S.of(context).allergy,
                    textInputType: TextInputType.text,
                    controller: ref.watch(allergyProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.defaultValidator(
                      value: value!,
                      hintText: S.of(context).allergy,
                      context: context,
                    ),
                  ),
                  Gap(20.h),

                  // Microchip Field
                  CustomTextFormField(
                    name: 'microchip',
                    focusNode: fNodeList[8],
                    hintText: S.of(context).microchip,
                    textInputType: TextInputType.text,
                    controller: ref.watch(microchipNumberProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.defaultValidator(
                      value: value!,
                      hintText: S.of(context).microchip,
                      context: context,
                    ),
                  ),
                  Gap(20.h),

                  // Description Field
                  CustomTextFormField(
                    name: 'Description',
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
                  Gap(20.h),

                  // Is Neuter Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).is_neutered,
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
                                            "Chưa thiến",
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
                                            "Đã thiến",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget({
    required bool isDark,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        border: Border(
          top: BorderSide(
            color: colors(context).bodyTextSmallColor!.withOpacity(0.1),
            width: 2,
          ),
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
                    buttonText: S.of(context).update,
                    buttonColor: colors(context).primaryColor,
                    onPressed: () async {
                      // Kiểm tra validation
                      if (ref.read(ridersFormKey).currentState!.validate()) {
                        final PetRequest petInfo = PetRequest(
                          name: ref.read(firstNameProvider).text,
                          description: ref.read(descriptionProvider).text,
                          sex: ref.read(genderProvider).text,
                          allergy: ref.read(allergyProvider).text,
                          behaviorCategoryId: int.parse(
                              ref.read(behaviorCategoryProvider).text),
                          isNeuter:
                              ref.read(isNeuterProvider).text.toLowerCase() ==
                                  'true',
                          petTypeId: int.parse(ref.read(petTypeProvider).text),
                          dob: DateFormat('yyyy-MM-dd').format(
                            DateFormat('MM/dd/yyyy')
                                .parse(ref.read(dateOfBirthProvider).text),
                          ),
                          weight: double.parse(ref.read(weightProvider).text),
                          microchipNumber:
                              ref.read(microchipNumberProvider).text,
                        );

                        // Xử lý ảnh
                        File imageFile;
                        if (_selectedImage != null) {
                          // Nếu người dùng đã chọn ảnh mới
                          imageFile = _selectedImage!;
                        } else {
                          // Nếu không có ảnh mới, giữ nguyên ảnh cũ
                          // Không cần tạo File từ URL nữa
                          if (widget.petDetail.image == null) {
                            GlobalFunction.showCustomSnackbar(
                              message: S.of(context).profileImageIsReq,
                              isSuccess: false,
                            );
                            return;
                          }
                          // Gửi null hoặc empty string để backend giữ nguyên ảnh cũ
                          imageFile = File('');
                        }

                        final response =
                            await ref.read(petController.notifier).updatePet(
                                  petRequest: petInfo,
                                  profile: imageFile,
                                  id: widget.petId,
                                );

                        if (response.isSuccess) {
                          GlobalFunction.showCustomSnackbar(
                            message: response.message,
                            isSuccess: true,
                          );
                          // Refresh pet list
                          ref.read(petController.notifier).getPetList();
                          Navigator.pop(context);
                        } else {
                          GlobalFunction.showCustomSnackbar(
                            message: response.message,
                            isSuccess: false,
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:fluffypawuser/models/profile/update_user_model.dart';
import 'package:fluffypawuser/utils/global_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfileLayout extends ConsumerStatefulWidget {
  const UserProfileLayout({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileLayout> createState() => _UserProfileLayoutState();
}

class _UserProfileLayoutState extends ConsumerState<UserProfileLayout> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _updateProfile(UserModel currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final updateData = UpdateUserModel(
        fullName: ref.read(firstNameProvider).text,
        gender: ref.read(genderProvider).text,
        phone: currentUser.phone,
        address: currentUser.address,
        email: currentUser.email,
        dob: ref.read(dateOfBirthProvider).text,
        avatar: ref.read(selectedUserProfileImage)?.path != null 
          ? File(ref.read(selectedUserProfileImage)!.path) 
          : null,
      );

      await ref.read(profileController.notifier).updateUserProfile(updateData);

      if (mounted) {
        GlobalFunction.showCustomSnackbar(
          message: 'Profile updated successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalFunction.showCustomSnackbar(
          message: 'Error updating profile: $e',
          isSuccess: false,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _initializeControllers(UserModel user) {
    ref.read(firstNameProvider).text = user.fullName;
    ref.read(genderProvider).text = user.gender;
    ref.read(dateOfBirthProvider).text = GlobalFunction.formateDate(user.dob);
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedUserProfileImage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(AppConstants.userBox).listenable(),
        builder: (context, userBox, _) {
          Map<dynamic, dynamic>? userInfo = userBox.get(AppConstants.userData);
          if (userInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> userInfoStringKeys = userInfo.cast<String, dynamic>();
          UserModel user = UserModel.fromMap(userInfoStringKeys);

          _initializeControllers(user);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.violetColor.withOpacity(0.2),
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: selectedImage != null
                                ? FileImage(File(selectedImage.path)) as ImageProvider
                                : CachedNetworkImageProvider(user.avatar),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColor.violetColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),

                  // Photo Selection Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => GlobalFunction.pickImageFromCamera(ref: ref),
                        child: _buildPhotoButton(
                          icon: Icons.camera_alt,
                          text: 'Camera',
                          isSelected: true,
                        ),
                      ),
                      Gap(12.w),
                      GestureDetector(
                        onTap: () => GlobalFunction.pickImageFromGallery(
                          ref: ref,
                          imageType: ImageType.userProfile,
                        ),
                        child: _buildPhotoButton(
                          icon: Icons.image,
                          text: 'Gallery',
                          isSelected: false,
                        ),
                      ),
                    ],
                  ),
                  Gap(32.h),

                  // Form Fields
                  _buildSectionTitle('Basic Information'),
                  Gap(16.h),

                  _buildFormField(
                    label: 'Full Name',
                    controller: ref.watch(firstNameProvider),
                    validator: (value) => GlobalFunction.firstNameValidator(
                      value: value ?? '',
                      hintText: 'Full Name',
                      context: context,
                    ),
                    prefixIcon: Icons.person_outline,
                  ),
                  Gap(16.h),

                  _buildFormField(
                    label: 'Email',
                    initialValue: user.email,
                    readOnly: true,
                    prefixIcon: Icons.email_outlined,
                  ),
                  Gap(16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Gender',
                          controller: ref.watch(genderProvider),
                          validator: (value) => GlobalFunction.defaultValidator(
                            value: value ?? '',
                            hintText: 'Gender',
                            context: context,
                          ),
                          prefixIcon: Icons.people_outline,
                          suffixIcon: Icons.arrow_drop_down,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => GlobalFunction.datePicker(
                            context: context,
                            ref: ref,
                          ),
                          child: _buildFormField(
                            label: 'Date of Birth',
                            controller: ref.watch(dateOfBirthProvider),
                            validator: (value) => GlobalFunction.dateOfBirthValidator(
                              value: value ?? '',
                              hintText: 'Date of Birth',
                              context: context,
                            ),
                            prefixIcon: Icons.calendar_today_outlined,
                            readOnly: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),

                  _buildFormField(
                    label: 'Phone Number',
                    initialValue: user.phone,
                    readOnly: true,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  Gap(32.h),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _updateProfile(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.violetColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColor.violetColor : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected ? AppColor.violetColor.withOpacity(0.1) : Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColor.violetColor : Colors.grey[600],
            size: 20.sp,
          ),
          Gap(8.w),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColor.violetColor : Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[600], size: 20.sp)
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[600], size: 20.sp)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.violetColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
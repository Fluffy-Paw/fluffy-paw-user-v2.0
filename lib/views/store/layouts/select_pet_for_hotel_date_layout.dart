import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:gap/gap.dart';

class SelectPetForHotelDateLayout extends ConsumerStatefulWidget {
  const SelectPetForHotelDateLayout({super.key});

  @override
  ConsumerState<SelectPetForHotelDateLayout> createState() => _SelectPetForHotelDateLayoutState();
}

class _SelectPetForHotelDateLayoutState extends ConsumerState<SelectPetForHotelDateLayout> {
  int? selectedPetId; // Chỉ cho phép chọn một thú cưng
  List<PetModel> pets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPets();
    });
  }

  Future<void> _loadPets() async {
    await ref.read(petController.notifier).getPetList();
    if (mounted) {
      setState(() {
        pets = ref.read(hiveStoreService).getPetInfo() ?? [];
      });
    }
  }

  void selectPet(int petId) {
    setState(() {
      // Nếu đang chọn rồi thì bỏ chọn, nếu chưa thì chọn mới
      selectedPetId = selectedPetId == petId ? null : petId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(petController);

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chọn thú cưng',
          style: AppTextStyle(context).title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColor.violetColor,
            ))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(20.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return _buildPetCard(
                                pet: pet,
                                isSelected: selectedPetId == pet.id,
                                onTap: () => selectPet(pet.id),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildPetCard({
    required PetModel pet,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.violetColor : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: pet.image ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.violetColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: AppTextStyle(context).subTitle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColor.violetColor : AppColor.blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(4.h),
                      Text(
                        '${pet.weight} kg',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: AppColor.violetColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: selectedPetId != null 
                ? () => Navigator.pop(context, selectedPetId)
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                disabledBackgroundColor: AppColor.violetColor.withOpacity(0.5),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Xác nhận',
                style: AppTextStyle(context).buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
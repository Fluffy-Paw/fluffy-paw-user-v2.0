import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;

  const PetCard({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Sử dụng context_less_navigation như trong code gốc của bạn
        context.nav.pushNamed(
          Routes.petDetail,
          arguments: pet.id,
        );

      },
      child: Material(
        color: AppColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Row(
            children: [
              // Avatar section
              Hero(
                tag: pet.id.toString(),
                child: CircleAvatar(
                  backgroundColor: AppColor.violetColor,
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(
                    pet.image ?? '',
                    errorListener: (e) {
                      debugPrint(e.toString());
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet name
                    Text(
                      pet.name,
                      style: AppTextStyle(context).subTitle.copyWith(
                            fontSize: 16,
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    // Weight info
                    Row(
                      children: [
                        Text(
                          "Weight: ",
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.blackColor.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          "${pet.weight}kg",
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.blackColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Behavior category
                    Text(
                      pet.behaviorCategory,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.blackColor.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
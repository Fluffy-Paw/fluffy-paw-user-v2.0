import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/components/confirmation_dialog.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/vaccine/vaccine_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/models/pet/pet_detail_model.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/views/pet/layouts/add_vaccine_layout.dart';
import 'package:fluffypawuser/views/pet/layouts/update_pet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PetDetailLayout extends ConsumerStatefulWidget {
  final int petId;

  const PetDetailLayout({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  ConsumerState<PetDetailLayout> createState() => _PetDetailLayoutState();
}

class _PetDetailLayoutState extends ConsumerState<PetDetailLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petController.notifier).getPetDetail(widget.petId);
      ref.read(vaccineController.notifier).getVaccineByPetId(widget.petId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        title: Text(widget.petId.toString()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Text(
              'Active',
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.processing, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Consumer(builder: (context, ref, _) {
        final isLoading =
            ref.watch(petController) || ref.watch(vaccineController);
        ;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final petDetail = ref.read(petController.notifier).petDetail;
        final vaccines = ref.read(vaccineController.notifier).vaccineList;
        if (petDetail == null) {
          return const Center(child: Text('No pet details found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(2.h),
              _buildInfoCardWidget(context: context, pet: petDetail),
              Gap(30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).petInfo,
                      style: AppTextStyle(context).title,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the UpdatePetLayout with petId and petTypeId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePetLayout(
                              petId: widget.petId,
                              petDetail: petDetail,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(Assets.svg.edit),
                          Gap(5.w),
                          Text(
                            S.of(context).edit,
                            style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColor.violetColor),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Gap(20.h),
              _buildPersonalInfoCard(context: context, pet: petDetail),
              Gap(20.h),
              _buildVaccineSection(context, vaccines ?? []),
              Gap(20.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCardWidget({
    required BuildContext context,
    required PetDetail pet,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14.r),
          bottomRight: Radius.circular(14.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: pet.id.toString(),
                child: CircleAvatar(
                  radius: 45.r,
                  backgroundImage: CachedNetworkImageProvider(
                    pet.image ?? '',
                    errorListener: (e) {
                      debugPrint(e.toString());
                    },
                  ),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: AppTextStyle(context).title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(5.h),
                    Text(
                      '${pet.weight} kg',
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                colors(context).bodyTextColor!.withOpacity(0.7),
                          ),
                    ),
                    Gap(5.h),
                    Text(
                      'DOB: ${pet.dob}',
                      style: AppTextStyle(context)
                          .bodyText
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard(
                type: 'category',
                text: S.of(context).petType,
                icon: Assets.svg.done,
                count: pet.petType.name,
                color: AppColor.lime500,
                context: context,
              ),
              _buildCard(
                type: 'behavior',
                text: S.of(context).behavior,
                icon: Assets.svg.doller,
                count: pet.behaviorCategory.name,
                color: AppColor.violetColor,
                context: context,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCard({
    required String type,
    required String text,
    required String icon,
    required String count,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyle(context)
                      .bodyTextSmall
                      .copyWith(fontSize: 13.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap(10.w),
              SvgPicture.asset(
                icon,
                height: 30,
                color: type == 'behavior' ? AppColor.violetColor : null,
              )
            ],
          ),
          Gap(10.h),
          Text(
            count,
            style: AppTextStyle(context).title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard({
    required BuildContext context,
    required PetDetail pet,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  title: S.of(context).petName,
                  value: pet.name,
                  context: context,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: _buildInfoColumn(
                  title: S.of(context).gender,
                  value: pet.sex,
                  context: context,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  title: S.of(context).dateOfBirth,
                  value: pet.dob,
                  context: context,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: _buildInfoColumn(
                  title: S.of(context).age,
                  value: pet.age,
                  context: context,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  title: 'Allergy',
                  value: pet.allergy,
                  context: context,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: _buildInfoColumn(
                  title: 'Microchip Number',
                  value: pet.microchipNumber,
                  context: context,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  title: 'Description',
                  value: pet.decription,
                  context: context,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: _buildInfoColumn(
                  title: 'Neutered',
                  value: pet.isNeuter ? 'Yes' : 'No',
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyle(context).bodyText.copyWith(
              color: colors(context).bodyTextSmallColor,
              fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap(10.h),
        Text(
          value,
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w500,
              ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVaccineSection(
      BuildContext context, List<VaccineModel> vaccines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vaccine History',
                style: AppTextStyle(context).title,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.addVaccine,
                    arguments: widget.petId,
                  ).then((_) {
                    // Làm mới danh sách vaccine khi quay lại từ màn hình thêm
                    ref
                        .read(vaccineController.notifier)
                        .getVaccineByPetId(widget.petId);
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColor.violetColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 16.sp,
                        color: AppColor.violetColor,
                      ),
                      Gap(4.w),
                      Text(
                        'Add',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: AppColor.violetColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(16.h),
        if (vaccines.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No vaccine records found',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: vaccines.length,
            itemBuilder: (context, index) {
              final vaccine = vaccines[index];
              return _buildVaccineCard(context, vaccine);
            },
          ),
      ],
    );
  }

  Widget _buildVaccineCard(BuildContext context, VaccineModel vaccine) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'expired':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.vaccineDetail,
              arguments: vaccine.id,
            ).then((_) {
              // Làm mới danh sách vaccine khi quay lại từ màn hình thêm
              ref
                  .read(vaccineController.notifier)
                  .getVaccineByPetId(widget.petId);
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: vaccine.image != null && vaccine.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: vaccine.image!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: Icon(
                                Icons.medical_services,
                                color: Colors.grey,
                                size: 30.sp,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.medical_services,
                                color: Colors.grey,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.grey,
                            size: 30.sp,
                          ),
                        ),
                ),
                Gap(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vaccine.name,
                              style: AppTextStyle(context).subTitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(vaccine.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              vaccine.status,
                              style:
                                  AppTextStyle(context).bodyTextSmall.copyWith(
                                        color: getStatusColor(vaccine.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Text(
                        DateFormat('dd MMM yyyy').format(vaccine.vaccineDate),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      Gap(4.h),
                      Text(
                        vaccine.description ?? 'Không có description',
                        style: AppTextStyle(context).bodyTextSmall,
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
      ),
    );
  }
  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          isLoading: ref.watch(petController),
          text: 'Are you sure you want to delete this pet?',
          image: Image.asset(Assets.image.question.path),
          cancelTapAction: () => Navigator.of(context).pop(),
          applyTapAction: () async {
            await ref.read(petController.notifier).deletePet(widget.petId);
            if (mounted) {
              Navigator.of(context).pop(); // Close dialog
              // Pop until we reach the list screen
              Navigator.of(context).popUntil(
                (route) => route.settings.name == Routes.petList,
              );
              // Refresh the pet list
              ref.read(petController.notifier).getPetList();
            }
          },
        );
      },
    );
  }
}

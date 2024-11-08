import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/vaccine/vaccine_controller.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class VaccineDetailLayout extends ConsumerStatefulWidget {
  final int vaccineId;

  const VaccineDetailLayout({
    Key? key,
    required this.vaccineId,
  }) : super(key: key);

  @override
  ConsumerState<VaccineDetailLayout> createState() =>
      _VaccineDetailLayoutState();
}

class _VaccineDetailLayoutState extends ConsumerState<VaccineDetailLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaccineController.notifier).getVaccineDetail(widget.vaccineId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Vaccine Detail',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(vaccineController);
          final vaccineDetail =
              ref.watch(vaccineController.notifier).vaccineDetail;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vaccineDetail == null) {
            return Center(
              child: Text(
                'No vaccine details found',
                style: AppTextStyle(context).bodyText,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageHeader(vaccineDetail),
                Gap(20.h),
                _buildInfoSection(vaccineDetail),
                Gap(20.h),
                _buildDatesSection(vaccineDetail),
                Gap(20.h),
                _buildDescriptionSection(vaccineDetail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageHeader(VaccineDetailModel vaccine) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: vaccine.image ?? 'https://storage-vnportal.vnpt.vn/btn-ubnd/sitefolders/ubnden/nam2021/thang9/h7.jpg',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 50.sp,
                  color: Colors.grey[400],
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 50.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.name,
                      style: AppTextStyle(context).title.copyWith(
                            color: Colors.white,
                            fontSize: 24.sp,
                          ),
                    ),
                    Gap(8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(vaccine.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        vaccine.status,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: _getStatusColor(vaccine.status),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(VaccineDetailModel vaccine) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.pets_outlined,
            title: 'Pet Weight',
            value: '${vaccine.petCurrentWeight} kg',
          ),
          Gap(16.h),
          _buildInfoRow(
            icon: Icons.numbers_outlined,
            title: 'Vaccine ID',
            value: '#${vaccine.id}',
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection(VaccineDetailModel vaccine) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        children: [
          _buildDateRow(
            icon: Icons.event_outlined,
            title: 'Vaccine Date',
            date: vaccine.vaccineDate,
          ),
          Gap(16.h),
          _buildDateRow(
            icon: Icons.event_repeat_outlined,
            title: 'Next Vaccine Date',
            date: vaccine.nextVaccineDate,
            isNext: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(VaccineDetailModel vaccine) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(8.h),
          Text(
            'Description',
            style: AppTextStyle(context).subTitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Gap(8.h),
          Text(
            vaccine.description ?? 'No description available',
            style: AppTextStyle(context).bodyText.copyWith(
                  color: vaccine.description != null
                      ? Colors.grey[600]
                      : Colors.grey[400],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.violetColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColor.violetColor,
            size: 24.sp,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: AppTextStyle(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String title,
    required DateTime date,
    bool isNext = false,
  }) {
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final daysRemaining = date.difference(DateTime.now()).inDays;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.violetColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColor.violetColor,
            size: 24.sp,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                formattedDate,
                style: AppTextStyle(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (isNext && daysRemaining > 0) ...[
                Gap(4.h),
                Text(
                  'In $daysRemaining days',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.violetColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
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
}

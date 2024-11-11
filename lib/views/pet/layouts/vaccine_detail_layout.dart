import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/vaccine/vaccine_controller.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_detail_model.dart';
import 'package:fluffypawuser/views/pet/layouts/update_vaccine_layout.dart';
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
  BuildContext? _dialogContext;
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
        actions: [
          // Edit button
          IconButton(
            onPressed: () => _navigateToUpdate(context),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.violetColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppColor.violetColor,
                size: 20.sp,
              ),
            ),
          ),
          // Delete button
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20.sp,
              ),
            ),
          ),
          Gap(16.w),
        ],
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
              imageUrl: vaccine.image ??
                  'https://storage-vnportal.vnpt.vn/btn-ubnd/sitefolders/ubnden/nam2021/thang9/h7.jpg',
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
          // Text(
          //   'Description',
          //   style: AppTextStyle(context).subTitle.copyWith(
          //         fontWeight: FontWeight.w600,
          //       ),
          // ),
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
      case 'Complete':
        return Colors.green;
      case 'Incomplete':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToUpdate(BuildContext context) {
    final vaccineDetail = ref.read(vaccineController.notifier).vaccineDetail;
    if (vaccineDetail != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateVaccineLayout(
            vaccineDetail: vaccineDetail,
          ),
        ),
      ).then((_) {
        // Refresh vaccine details after update
        ref.read(vaccineController.notifier).getVaccineDetail(widget.vaccineId);
      });
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32.sp,
                ),
              ),
              Gap(16.h),
              Text(
                'Delete Vaccine',
                style: AppTextStyle(context).title.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Gap(8.h),
              Text(
                'Are you sure you want to delete this vaccine record? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Gap(24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteVaccine(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteVaccine(BuildContext context) async {
    try {
      // Close confirmation dialog
      Navigator.of(context).pop();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _dialogContext = context;  // Store dialog context
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.violetColor),
                    ),
                    Gap(16.h),
                    Text(
                      'Deleting vaccine...',
                      style: AppTextStyle(context).bodyText,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Call delete API
      final success = await ref.read(vaccineController.notifier).deleteVaccine(widget.vaccineId);

      // Close loading dialog
      if (_dialogContext != null && mounted) {
        Navigator.of(_dialogContext!).pop();
      }

      if (success && mounted) {
        // Navigate back to previous screen
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vaccine deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete vaccine'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (_dialogContext != null && mounted) {
        Navigator.of(_dialogContext!).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while deleting the vaccine'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Error deleting vaccine: $e');
    } finally {
      // Clear dialog context
      _dialogContext = null;
    }
  }

}

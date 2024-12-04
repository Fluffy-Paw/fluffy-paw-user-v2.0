import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/report/report_controller.dart';
import 'package:fluffypawuser/models/report/report_model.dart';
import 'package:fluffypawuser/views/report/report_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final int targetId;

  const ReportScreen({Key? key, required this.targetId}) : super(key: key);

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _descriptionController = TextEditingController();
  ReportCategory? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadCategories());
  }

  Future<void> _loadCategories() async {
    await ref.read(reportController.notifier).getAllReportCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reportController);
    final categories =
        ref.read(reportController.notifier).reportCategories ?? [];

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        title: Text(
          'Báo cáo',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Lý do báo cáo'),
                    Gap(8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return RadioListTile<ReportCategory>(
                            value: category,
                            groupValue: _selectedCategory,
                            onChanged: (value) {
                              setState(() => _selectedCategory = value);
                            },
                            title: Text(
                              category.name,
                              style: AppTextStyle(context).bodyText,
                            ),
                            activeColor: AppColor.violetColor,
                          );
                        },
                      ),
                    ),
                    Gap(24.h),
                    _buildSectionTitle('Mô tả chi tiết'),
                    Gap(8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả chi tiết về vấn đề của bạn...',
                          hintStyle: AppTextStyle(context).bodyText.copyWith(
                                color: Colors.grey[400],
                              ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColor.whiteColor,
                          contentPadding: EdgeInsets.all(16.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Gửi báo cáo',
                      style: AppTextStyle(context).buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle(context).title.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null) {
      _showError('Vui lòng chọn lý do báo cáo');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Vui lòng nhập mô tả chi tiết');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ReportRequest(
        targetId: widget.targetId,
        reportCategoryId: _selectedCategory!.id,
        description: _descriptionController.text.trim(),
      );

      final response =
          await ref.read(reportController.notifier).createReport(request);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportSuccessScreen(
                onContinue: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.settings.name == '/booking-history',
                  );
                },
              ),
            ),
          );
        }
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

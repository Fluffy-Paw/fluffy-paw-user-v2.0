import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/rating/rating_controller.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';

class CreateRatingScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String storeName;

  const CreateRatingScreen({
    Key? key,
    required this.bookingId,
    required this.storeName,
  }) : super(key: key);

  @override
  ConsumerState<CreateRatingScreen> createState() => _CreateRatingScreenState();
}

class _CreateRatingScreenState extends ConsumerState<CreateRatingScreen> {
  int _serviceRating = 0;
  int _storeRating = 0;
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      _showErrorSnackbar('Không thể chọn ảnh: $e');
    }
  }

  Future<void> _submitRating() async {
    if (_serviceRating == 0 || _storeRating == 0) {
      _showErrorSnackbar(
          'Vui lòng chọn số sao đánh giá cho cả dịch vụ và cửa hàng');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = BookingRatingRequest(
        serviceVote: _serviceRating,
        storeVote: _storeRating,
        description: _descriptionController.text,
        image: _selectedImage,
      );

      await ref.read(bookingRatingController.notifier).createRating(
            widget.bookingId,
            request,
          );

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackbar('Đánh giá thành công!');
      }
    } catch (e) {
      if (mounted && e.toString().contains('Failed to create rating')) {
        _showErrorSnackbar('Không thể tạo đánh giá');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            Gap(8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColor.redColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            Gap(8.w),
            Text(message),
          ],
        ),
        backgroundColor: AppColor.lime500,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
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
          'Đánh giá dịch vụ',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đánh giá dịch vụ'),
                  _buildRatingStars(_serviceRating, (rating) {
                    setState(() => _serviceRating = rating);
                  }),
                  Gap(16.h),
                  Text('Đánh giá cửa hàng'),
                  _buildRatingStars(_storeRating, (rating) {
                    setState(() => _storeRating = rating);
                  }),
                  Gap(24.h),
                  Text(
                    'Nhận xét của bạn',
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Gap(8.h),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn...',
                      hintStyle: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey[500],
                          ),
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
                    ),
                  ),
                  Gap(16.h),
                  Text(
                    'Thêm hình ảnh (không bắt buộc)',
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Gap(8.h),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () =>
                                        setState(() => _selectedImage = null),
                                    icon: Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48.sp,
                                  color: Colors.grey[500],
                                ),
                                Gap(8.h),
                                Text(
                                  'Thêm hình ảnh',
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            color: Colors.grey[500],
                                          ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.violetColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Gửi đánh giá',
                  style: AppTextStyle(context).bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(int currentRating, Function(int) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              index < currentRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: Colors.amber,
              size: 48.sp,
            ),
          ),
        );
      }),
    );
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/rating/rating_controller.dart';
import 'package:fluffypawuser/models/rating/booking_rating_model.dart';
import 'package:fluffypawuser/views/booking/layouts/create_rating_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class BookingRatingDetailsScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String storeName;

  const BookingRatingDetailsScreen({
    Key? key,
    required this.bookingId,
    required this.storeName,
  }) : super(key: key);

  @override
  ConsumerState<BookingRatingDetailsScreen> createState() =>
      _BookingRatingDetailsScreenState();
}

class _BookingRatingDetailsScreenState
    extends ConsumerState<BookingRatingDetailsScreen> {
  bool _isEditing = false;
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isUpdating = false;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    // Schedule the provider update for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRating();
    });
  }

  Future<void> _loadRating() async {
    if (!mounted) return;
    try {
      await ref
          .read(bookingRatingController.notifier)
          .getRating(widget.bookingId);
    } catch (e) {
      debugPrint('Rating not found or error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingRating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingRatingController);
    final rating = ref.watch(bookingRatingController.notifier).bookingRating;
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
        appBar: AppBar(
          backgroundColor: AppColor.whiteColor,
          elevation: 0,
          title: Text(
            'Chi tiết đánh giá',
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (rating == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateRatingScreen(
              bookingId: widget.bookingId,
              storeName: widget.storeName,
            ),
          ),
        );
      });
      return Container();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Chi tiết đánh giá',
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
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _isEditing = false;
                  _descriptionController.text = rating.description ?? '';
                  _selectedImage = null;
                });
              } else {
                setState(() {
                  _isEditing = true;
                  _descriptionController.text = rating.description ?? '';
                });
              }
            },
          ),
        ],
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
                  Text(
                    widget.storeName,
                    style: AppTextStyle(context).title.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.violetColor,
                        ),
                  ),
                  Gap(24.h),
                  _buildRatings(rating),
                  Gap(24.h),
                  if (_isEditing) ...[
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ trải nghiệm của bạn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ] else if (rating.description != null) ...[
                    Text(
                      'Nhận xét',
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Gap(8.h),
                    Text(
                      rating.description!,
                      style: AppTextStyle(context).bodyText,
                    ),
                  ],
                  Gap(16.h),
                  if (rating.image != null || _selectedImage != null) ...[
                    Text(
                      'Hình ảnh',
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Gap(8.h),
                    if (_isEditing)
                      _buildImagePicker(rating.image)
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          rating.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Container(
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
                onPressed: _isUpdating ? null : () => _updateRating(rating),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.violetColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isUpdating
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Cập nhật đánh giá',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildRatings(BookingRating rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá dịch vụ',
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (_isEditing)
          _buildEditableStarRow(rating.serviceVote, (newRating) {
            setState(() => rating.serviceVote = newRating);
          })
        else
          _buildStarRow(rating.serviceVote),
        Gap(16.h),
        Text(
          'Đánh giá cửa hàng',
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (_isEditing)
          _buildEditableStarRow(rating.storeVote, (newRating) {
            setState(() => rating.storeVote = newRating);
          })
        else
          _buildStarRow(rating.storeVote),
      ],
    );
  }

  Widget _buildEditableStarRow(
      int currentRating, Function(int) onRatingChanged) {
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

  Widget _buildStarRow(int vote) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < vote ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 48.sp,
        );
      }),
    );
  }

  Widget _buildImagePicker(String? currentImage) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
                      onPressed: () => setState(() => _selectedImage = null),
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
            : currentImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      currentImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  Future<void> _updateRating(BookingRating currentRating) async {
    setState(() => _isUpdating = true);

    try {
      final Map<String, dynamic> formData = {
        'ServiceVote': currentRating.serviceVote.toString(),
        'StoreVote': currentRating.storeVote.toString(),
        'Description': _descriptionController.text,
      };

      if (_selectedImage != null) {
        formData['Image'] = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.name,
        );
      }

      final result = await ref
          .read(bookingRatingController.notifier)
          .updateRating(currentRating.id, formData);

      if (result.isSuccess) {
        // Reload rating data first
        await ref
            .read(bookingRatingController.notifier)
            .getRating(widget.bookingId);

        if (mounted) {
          setState(() {
            _isEditing = false;
            _selectedImage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  Gap(8.w),
                  Text('Cập nhật đánh giá thành công'),
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
      } else {
        _showErrorSnackbar('Không thể cập nhật đánh giá');
      }
    } catch (e) {
      debugPrint('Error updating rating: $e');
      _showErrorSnackbar('Đã xảy ra lỗi khi cập nhật đánh giá');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
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
}

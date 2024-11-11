import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/vaccine/vaccine_controller.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_detail_model.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateVaccineLayout extends ConsumerStatefulWidget {
  final VaccineDetailModel vaccineDetail;

  const UpdateVaccineLayout({
    Key? key,
    required this.vaccineDetail,
  }) : super(key: key);

  @override
  ConsumerState<UpdateVaccineLayout> createState() => _UpdateVaccineLayoutState();
}

class _UpdateVaccineLayoutState extends ConsumerState<UpdateVaccineLayout> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  late DateTime _vaccineDate;
  late DateTime _nextVaccineDate;
  File? _selectedImage;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vaccineDetail.name);
    _weightController = TextEditingController(
        text: widget.vaccineDetail.petCurrentWeight.toString());
    _descriptionController =
        TextEditingController(text: widget.vaccineDetail.description);
    _vaccineDate = widget.vaccineDetail.vaccineDate;
    _nextVaccineDate = widget.vaccineDetail.nextVaccineDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Update Vaccine',
          style: AppTextStyle(context).title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              Gap(20.h),
              _buildTextField(
                controller: _nameController,
                label: 'Vaccine Name',
                placeholder: 'Enter vaccine name',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter vaccine name';
                  }
                  return null;
                },
              ),
              Gap(16.h),
              _buildTextField(
                controller: _weightController,
                label: 'Current Weight (kg)',
                placeholder: 'Enter pet\'s current weight',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              Gap(16.h),
              _buildDatePicker(
                label: 'Vaccine Date',
                date: _vaccineDate,
                onChanged: (date) {
                  setState(() {
                    _vaccineDate = date;
                    // Auto update next vaccine date
                    _nextVaccineDate = date.add(const Duration(days: 30));
                  });
                },
              ),
              Gap(16.h),
              _buildDatePicker(
                label: 'Next Vaccine Date',
                date: _nextVaccineDate,
                onChanged: (date) {
                  setState(() {
                    _nextVaccineDate = date;
                  });
                },
              ),
              Gap(16.h),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                placeholder: 'Enter vaccine description',
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: widget.vaccineDetail.image ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 40.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 40.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColor.violetColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(8.h),
        GestureDetector(
          onTap: () => _showDatePicker(date, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: AppTextStyle(context).bodyText,
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isLoading = ref.watch(vaccineController);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.violetColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Update Vaccine',
                  style: AppTextStyle(context).buttonText,
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageChanged = true;
      });
    }
  }

  Future<void> _showDatePicker(DateTime initialDate, Function(DateTime) onChanged) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  onDateTimeChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final request = VaccineRequest(
        petId: widget.vaccineDetail.petId,
        name: _nameController.text,
        vaccineImage: _selectedImage ?? File(''), // This will be handled in form data
        petCurrentWeight: int.parse(_weightController.text),
        vaccineDate: DateFormat('yyyy-MM-dd').format(_vaccineDate),
        nextVaccineDate: DateFormat('yyyy-MM-dd').format(_nextVaccineDate),
        description: _descriptionController.text,
      );

      // Create form data
      final formData = FormData.fromMap({
        'PetId': request.petId.toString(),
        'Name': request.name,
        'PetCurrentWeight': request.petCurrentWeight.toString(),
        'VaccineDate': request.vaccineDate,
        'NextVaccineDate': request.nextVaccineDate,
        'Description': request.description,
      });

      // Only add image if user selected a new one
      if (_imageChanged && _selectedImage != null) {
        formData.files.add(
          MapEntry(
            'VaccineImage',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.path.split('/').last,
              contentType: DioMediaType('image', _selectedImage!.path.split('.').last),
            ),
          ),
        );
      }

      final success = await ref.read(vaccineController.notifier).updateVaccineForPet(
        formData: formData,  // Pass formData instead of request and image
        vaccineId: widget.vaccineDetail.id,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vaccine updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update vaccine'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error updating vaccine: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
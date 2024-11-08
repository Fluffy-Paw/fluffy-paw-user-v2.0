import 'dart:io';
import 'package:fluffypawuser/controllers/vaccine/vaccine_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/models/vaccine/vaccine_request.dart';

class AddVaccineLayout extends ConsumerStatefulWidget {
  final int petId;

  const AddVaccineLayout({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  ConsumerState<AddVaccineLayout> createState() => _AddVaccineLayoutState();
}

class _AddVaccineLayoutState extends ConsumerState<AddVaccineLayout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _vaccineDate = DateTime.now();
  DateTime _nextVaccineDate = DateTime.now().add(const Duration(days: 30));
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Add Vaccine Record',
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
                    // Automatically set next vaccine date to 30 days after
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40.sp,
                    color: Colors.grey[400],
                  ),
                  Gap(8.h),
                  Text(
                    'Add Vaccine Image',
                    style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
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
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.violetColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Add Vaccine Record',
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
    
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a vaccine image')),
      );
      return;
    }

    try {
      final request = VaccineRequest(
        petId: widget.petId,
        name: _nameController.text,
        vaccineImage: _selectedImage!,
        petCurrentWeight: int.parse(_weightController.text),
        vaccineDate: DateFormat('yyyy-MM-dd').format(_vaccineDate),
        nextVaccineDate: DateFormat('yyyy-MM-dd').format(_nextVaccineDate),
        description: _descriptionController.text,
      );

      final success = await ref.read(vaccineController.notifier).addVaccineForPet(
        request: request,
        vaccineImage: _selectedImage!,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vaccine record added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vaccine record')),
      );
    }
  }
}
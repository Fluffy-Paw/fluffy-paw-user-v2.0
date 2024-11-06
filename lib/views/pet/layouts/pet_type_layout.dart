import 'package:fluffypawuser/views/pet/layouts/create_pet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';

class PetTypeSelect extends StatefulWidget {
  const PetTypeSelect({super.key});

  @override
  _PetTypeSelectState createState() => _PetTypeSelectState();
}

class _PetTypeSelectState extends State<PetTypeSelect> {
  int? selectedPetType; // 1 cho chó, 2 cho mèo

  void selectPetType(int type) {
    setState(() {
      selectedPetType = type;
    });
  }

  void _confirmSelection() {
    if (selectedPetType != null) {
      // Chuyển trang sang CreatePetLayout với tham số petType
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePetLayout(petType: selectedPetType!),
        ),
      );
    } else {
      // Hiển thị thông báo nếu người dùng chưa chọn loại pet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại thú cưng')),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn loại thú cưng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What type of pet is it?',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1,
              children: [
                _buildPetCard(
                  type: 'Dog',
                  backgroundColor: const Color(0xFFFFB74D),
                  svgPath: Assets.svg.dogType, // Đường dẫn đến file SVG chó
                  isSelected: selectedPetType == 1,
                  onTap: () => selectPetType(1),
                ),
                _buildPetCard(
                  type: 'Cat',
                  backgroundColor: const Color(0xFF90CAF9),
                  svgPath: Assets.svg.catType, // Đường dẫn đến file SVG mèo
                  isSelected: selectedPetType == 2,
                  onTap: () => selectPetType(2),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Center(
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard({
    required String type,
    required Color backgroundColor,
    required String svgPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 5 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: 64.w,
                    height: 64.w,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.blueAccent : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

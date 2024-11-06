import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeLayout extends ConsumerStatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeLayout> {
  List<PetModel> pets = [];
  UserModel? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      // Load user data
      final userBox = await Hive.openBox(AppConstants.userBox);
      final userData = userBox.get(AppConstants.userData);
      if (userData != null) {
        userInfo = UserModel.fromMap(Map<String, dynamic>.from(userData));
      }

      // Load pet data
      final petBox = await Hive.openBox(AppConstants.petBox);
      final petData =
          petBox.get(AppConstants.petData, defaultValue: []) as List;
      pets = petData
          .map((data) => PetModel.fromMap(Map<String, dynamic>.from(data)))
          .toList();
          await ref.read(storeController.notifier).getServiceTypeList();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  Map<String, String> serviceIconMap = {
    'Grooming': Assets.svg.petGrooming,
    'Hotel': Assets.svg.petHotel,
    'Training': Assets.svg.petTraining,
    'Vaccine': Assets.svg.petVaccine,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData, // Pull-to-refresh action
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: [
                       _buildAppBar(),
                      SizedBox(height: 110.h),
                      _buildIconContainer(), // Thêm container chứa các icon
                      SizedBox(height: 20.h), // Khoảng cách giữa các phần
                      _buildPetList(),
                        
                      ],
                    ),
                    Positioned(
                      top: 200.h,
                      left: 0,
                      right: 0,
                      child: _buildPetCardContainer(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image từ local
          Container(
            height: 250.h,
            width: double.infinity,
            child: Image.asset(
              Assets.image.background.path, // Tên file ảnh của bạn
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image: $error");
                return Container(
                  color: colors(context).primaryColor ??
                      Theme.of(context).primaryColor,
                );
              },
            ),
          ),
          // Gradient overlay
          Container(
            height: 250.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.w, right: 20.w, top: 60.h, bottom: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    // child: CircleAvatar(
                    //   radius: 28.r,
                    //   backgroundColor: Colors.white,
                    //   child: ClipOval(
                    //     child: Image.network(
                    //       userInfo?.avatar ?? 'https://via.placeholder.com/56',
                    //       width: 56.w,
                    //       height: 56.h,
                    //       fit: BoxFit.cover,
                    //       errorBuilder: (context, error, stackTrace) {
                    //         return Icon(Icons.person, size: 30.sp);
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Xin chào, ${userInfo?.fullName ?? "User"}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIconContainer() {
  final serviceTypes = ref.watch(storeController.notifier).petTypes;
  print('Service Types: ${serviceTypes?.map((e) => '${e.name}: ${e.id}')}');

  // Thêm consumer để lắng nghe thay đổi từ controller
  return Consumer(
    builder: (context, ref, child) {
      // Kiểm tra null/empty nhưng vẫn return container rỗng thay vì SizedBox.shrink()
      if (serviceTypes == null || serviceTypes.isEmpty) {
        print('Service Types is null or empty');
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: serviceTypes.map((service) {
            // Hardcode service icons nếu API name không khớp
            String iconPath;
            switch(service.name.toLowerCase()) {
              case 'grooming':
                iconPath = Assets.svg.petGrooming;
                break;
              case 'hotel':
                iconPath = Assets.svg.petHotel;
                break;
              case 'training':
                iconPath = Assets.svg.petTraining;
                break;
              case 'vaccine':
                iconPath = Assets.svg.petVaccine;
                break;
              default:
                iconPath = Assets.svg.petGrooming;
            }
            
            print('Rendering service: ${service.name} with icon: $iconPath');
            
            return Expanded(
              child: _buildIconButton(
                iconPath,
                service.name,
                () {
                  print('Service tapped: ${service.name} (ID: ${service.id})');
                },
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

Widget _buildIconButton(String iconPath, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              color: colors(context).accentColor?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colors(context).primaryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 32.w,
                height: 32.w,
                placeholderBuilder: (BuildContext context) => Icon(
                  Icons.error,
                  size: 32.w,
                  color: colors(context).primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    ),
  );
}
  Widget _buildPetCardContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 150.h,
        child: pets.isEmpty
            ? _buildAddNewPetCard()
            : PageView(
                children: [
                  ...pets.map((pet) => _buildPetCard(pet)),
                  _buildAddNewPetCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13.9.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).hintColor,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            'Tìm kiếm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(PetModel pet) {
    final primaryColor =
        colors(context).primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: Colors.white,  // Đổi thành màu nền trắng đục
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors(context).primaryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(19.5.w, 14.5.h, 19.5.w, 14.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    pet.petCategoryId == 2
                        ? "Mèo"
                        : pet.petCategoryId == 1
                            ? "Chó"
                            : "meo",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors(context).primaryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  pet.image ?? 'https://via.placeholder.com/60',
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        pet.petCategoryId == 2 ? Icons.pets : Icons.pets,
                        size: 24.sp,
                        color: primaryColor,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: primaryColor,
                        strokeWidth: 2.w,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
  Widget _buildPetList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động gần đây',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 10.h),
          ListView.builder(
            shrinkWrap: true, // Thêm này
            physics: NeverScrollableScrollPhysics(), // Và này
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _buildPetActivityItem(pet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetActivityItem(PetModel pet) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              pet.image ?? 'https://via.placeholder.com/50',
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50.w,
                  height: 50.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.pets, color: Colors.grey[400]),
                );
              },
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 5.h),
                Text(
                  pet.petCategoryId == 2 ? "Mèo" : "Chó",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewPetCard() {
    return GestureDetector(
      onTap: () {
        debugPrint('Navigating to selectPetType');
        Navigator.of(context).pushNamed(Routes.selectPetType);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.white,  // Đổi thành màu nền trắng đục
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: colors(context).primaryColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(19.5.w, 14.5.h, 19.5.w, 14.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
                size: 30.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Thêm thú cưng mới',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
}

  Widget _buildPetImage(String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl ?? 'https://logowik.com/content/uploads/images/cat8600.jpg',
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://logowik.com/content/uploads/images/cat8600.jpg',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng!';
    if (hour < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

 
}
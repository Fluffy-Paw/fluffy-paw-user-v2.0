import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/pet/service_type_model.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/recommend_service/recommended_Services_Screen.dart';
import 'package:fluffypawuser/views/store/layouts/service_detail_layout.dart';
import 'package:fluffypawuser/views/store/layouts/store_list_by_service_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomeLayout extends ConsumerStatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeLayout> {
  UserModel? userInfo;
  bool isLoading = true;
  List<StoreServiceModel>? recommendedServices;
  late final Box petBox;
  late final ValueListenable<Box> petBoxListenable;
  

  @override
  void initState() {
    super.initState();
    _setupBoxes();
    _initializeData();
  }

  Future<void> _setupBoxes() async {
    petBox = await Hive.openBox(AppConstants.petBox);
    petBoxListenable = petBox.listenable();
  }

  Future<void> _initializeData() async {
    await loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      // Load user data
      final userBox = await Hive.openBox(AppConstants.userBox);
      final userData = userBox.get(AppConstants.userData);
      if (userData != null) {
        userInfo = UserModel.fromMap(Map<String, dynamic>.from(userData));
      }

      await ref.read(storeController.notifier).getServiceTypeList();
      await ref.read(storeController.notifier).getTop6Services();
      recommendedServices = ref.read(storeController.notifier).recommendedServices;
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  List<PetModel> _getPetsFromBox() {
    final petData = petBox.get(AppConstants.petData, defaultValue: []) as List;
    return petData
        .map((data) => PetModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  Map<String, String> serviceIconMap = {
    'Grooming': Assets.svg.petGrooming,
    'Hotel': Assets.svg.petHotel,
    'Training': Assets.svg.petTraining,
    'Vaccine': Assets.svg.petVaccine,
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await loadData();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            child: isLoading
                ? _buildLoadingState()
                : _buildContent(),
          ),
        ),
      ),
    );
  }
   Widget _buildLoadingState() {
    return Column(
      children: [
        _buildShimmerHeader(),
        SizedBox(height: 110.h),
        _buildShimmerServiceIcons(),
        SizedBox(height: 20.h),
        _buildShimmerPetCard(),
        SizedBox(height: 30.h),
        _buildShimmerRecommendedServices(),
      ],
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Column(
          children: [
            _buildAppBar(),
            SizedBox(height: 110.h),
            _buildIconContainer(),
            SizedBox(height: 20.h),
            _buildTop6Services(),
          ],
        ),
        Positioned(
          top: 200.h,
          left: 0,
          right: 0,
          child: _buildPetCardContainer(),
        ),
      ],
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 250.h,
        child: Stack(
          children: [
            Container(
              height: 250.h,
              color: Colors.white,
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: 200.w,
                      height: 24.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 150.w,
                      height: 16.h,
                      color: Colors.white,
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

  Widget _buildShimmerRecommendedServices() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200.w,
              height: 24.h,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerServiceIcons() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (index) => Column(
              children: [
                Container(
                  width: 65.w,
                  height: 65.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 50.w,
                  height: 14.h,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPetCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 150.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }

  Widget _buildShimmerActivityList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150.w,
              height: 24.h,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: 250.h,
            width: double.infinity,
            child: Image.asset(
              Assets.image.background.path,
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
          // Notification button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20.w,
            child: _buildNotificationButton(),
          ),
          // User info content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.w, right: 20.w, top: 60.h, bottom: 20.h),
              child: _buildUserInfo(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildUserInfo() {
    return Column(
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
    );
  }
  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Routes.notification),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            SvgPicture.asset(
              Assets.svg.notification,
              width: 24.w,
              height: 24.w,
              color: colors(context).primaryColor,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    final serviceTypes = ref.watch(storeController.notifier).petTypes;

    return Consumer(
      builder: (context, ref, child) {
        if (serviceTypes == null || serviceTypes.isEmpty) {
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
              // Không cần switch-case nữa vì sẽ dùng image từ API
              return Expanded(
                child: _buildIconButton(
                  service.image, // Sử dụng image từ API
                  service.name,
                  () {
                    context.nav.pushNamed(
                      Routes.storeServiceByType,
                      arguments: StoreListArguments(
                        serviceTypeId: service.id,
                        serviceTypeName: service.name,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(String imageUrl, String label, VoidCallback onTap) {
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
                  color: colors(context).primaryColor?.withOpacity(0.2) ??
                      Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  imageUrl,
                  width: 65.w,
                  height: 65.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.pets,
                    size: 32.w,
                    color: colors(context).primaryColor,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.w,
                        color: colors(context).primaryColor,
                      ),
                    );
                  },
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
        child: ValueListenableBuilder(
          valueListenable: petBoxListenable,
          builder: (context, Box box, _) {
            final pets = _getPetsFromBox();
            return pets.isEmpty
                ? _buildAddNewPetCard()
                : PageView(
                    children: [
                      ...pets.map((pet) => _buildPetCard(pet)),
                      _buildAddNewPetCard(),
                    ],
                  );
          },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors(context).primaryColor?.withOpacity(0.2) ??
              Colors.grey.withOpacity(0.2),
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
                    pet.petCategoryId == 2 ? "Mèo" : "Chó",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildPetAvatar(pet, primaryColor),
          ],
        ),
      ),
    );
  }
  Widget _buildPetAvatar(PetModel pet, Color primaryColor) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors(context).primaryColor?.withOpacity(0.2) ??
              Colors.grey.withOpacity(0.2),
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
                Icons.pets,
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
    );
  }

  Widget _buildTop6Services() {
  final top6Services = ref.watch(storeController.notifier).top6Services;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dịch vụ nổi bật',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendedServicesScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: colors(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: colors(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),
      SizedBox(
        height: 250.h, // Tăng chiều cao container
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          scrollDirection: Axis.horizontal,
          itemCount: top6Services?.length ?? 0,
          itemBuilder: (context, index) {
            final service = top6Services![index];
            return _buildTop6ServiceCard(service);
          },
        ),
      ),
    ],
  );
}

Widget _buildTop6ServiceCard(StoreServiceModel service) {
  return Container(
    width: 200.w, // Giảm chiều rộng card
    margin: EdgeInsets.only(right: 16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailLayout(
                service: service,
                storeId: null,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            SizedBox(
              height: 130.h,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  service.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.pets,
                        size: 40.sp,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content container
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Add this
                  children: [
                    // Service type tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors(context).primaryColor?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        service.serviceTypeName,
                        style: TextStyle(
                          color: colors(context).primaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Service name
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 14.sp, // Giảm font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              service.totalRating.toString(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${NumberFormat.decimalPattern().format(service.cost)}',
                          style: TextStyle(
                            color: colors(context).primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      onTap: () async {
        await Navigator.of(context).pushNamed(Routes.selectPetType);
        if (mounted) {
          await ref.read(petController.notifier).getPetList();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: colors(context).primaryColor?.withOpacity(0.2) ??
                Colors.grey.withOpacity(0.2),
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

class StoreListArguments {
  final int serviceTypeId;
  final String serviceTypeName;

  StoreListArguments({
    required this.serviceTypeId,
    required this.serviceTypeName,
  });
}

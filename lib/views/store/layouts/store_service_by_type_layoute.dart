import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/components/store_card.dart';
import 'package:fluffypawuser/views/store/components/store_service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class StoreServiceListLayout extends ConsumerStatefulWidget {
  final int serviceTypeId;
  final String serviceTypeName;

  const StoreServiceListLayout({
    Key? key,
    required this.serviceTypeId,
    required this.serviceTypeName,
  }) : super(key: key);

  @override
  ConsumerState<StoreServiceListLayout> createState() =>
      _StoreServiceListLayoutState();
}

class _StoreServiceListLayoutState
    extends ConsumerState<StoreServiceListLayout> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(storeController.notifier)
          .getStoreServiceWithServiceTypeStoreId(widget.serviceTypeId);
      ref
          .read(storeController.notifier)
          .getStoresByServiceType(widget.serviceTypeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabs(),
          Expanded(
            child:
                _selectedIndex == 0 ? _buildServiceGrid() : _buildStoreList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColor.whiteColor,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Dịch vụ',
              icon: Icons.miscellaneous_services,
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildTabButton(
              title: 'Cửa hàng',
              icon: Icons.store,
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColor.violetColor : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColor.greyColor,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColor.whiteColor : AppColor.blackColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColor.whiteColor : AppColor.blackColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20.w,
        right: 20.w,
        bottom: 15.h,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          Gap(10.h),
          Text(
            widget.serviceTypeName,
            style: AppTextStyle(context).title,
          ),
          Gap(15.h),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: _selectedIndex == 0
            ? 'Tìm kiếm dịch vụ...'
            : 'Tìm kiếm cửa hàng...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(storeController);
        final services = ref.watch(storeController.notifier).serviceTypeServices;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (services == null || services.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy dịch vụ nào',
              style: AppTextStyle(context).bodyText,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(storeController.notifier)
                .getStoreServiceWithServiceTypeStoreId(widget.serviceTypeId);
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return StoreServiceCard(service: services[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildStoreList() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(storeController);
        final stores = ref.watch(storeController.notifier).storesByService;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stores == null || stores.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy cửa hàng nào',
              style: AppTextStyle(context).bodyText,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(storeController.notifier)
                .getStoresByServiceType(widget.serviceTypeId);
          },
          child: AnimationLimiter(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: StoreCard(store: stores[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

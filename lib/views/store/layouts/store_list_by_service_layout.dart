import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/views/store/components/store_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class StoreListByServiceLayout extends ConsumerStatefulWidget {
  final int serviceTypeId;
  final String serviceTypeName;

  const StoreListByServiceLayout({
    Key? key,
    required this.serviceTypeId,
    required this.serviceTypeName,
  }) : super(key: key);

  @override
  ConsumerState<StoreListByServiceLayout> createState() => _StoreListByServiceLayoutState();
}

class _StoreListByServiceLayoutState extends ConsumerState<StoreListByServiceLayout> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeController.notifier).getStoresByServiceType(widget.serviceTypeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildStoreList()),
        ],
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
            style: AppTextStyle(context).title.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
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
        hintText: 'Tìm kiếm cửa hàng...',
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
            await ref.read(storeController.notifier)
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
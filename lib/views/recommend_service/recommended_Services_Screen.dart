import 'dart:async';

import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';
import 'package:fluffypawuser/views/store/layouts/service_detail_layout.dart';
import 'package:fluffypawuser/views/store/layouts/store_service_by_type_layoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RecommendedServicesScreen extends ConsumerStatefulWidget {
  @override
  _RecommendedServicesScreenState createState() =>
      _RecommendedServicesScreenState();
}

class _RecommendedServicesScreenState
    extends ConsumerState<RecommendedServicesScreen> {
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;
  int _currentBannerIndex = 0;
  late Timer _bannerTimer;
  int? _selectedServiceTypeId;
  final PageController _bannerController = PageController();

  final List<String> bannerImages = [
    'https://firebasestorage.googleapis.com/v0/b/fluffy-paw-8e7c1.appspot.com/o/images%2Fdd52a47c-03ff-48eb-a5c2-cf608c9f2f86_Screenshot%202024-12-04%20at%2002.11.30.png?alt=media&token=51a74d39-8cba-4fbb-b609-867974947794',
    'https://firebasestorage.googleapis.com/v0/b/fluffy-paw-8e7c1.appspot.com/o/images%2F946b8aef-75af-4719-b955-edc25c1bd698_Screenshot%202024-12-04%20at%2002.12.17.png?alt=media&token=5a686296-de80-4abd-963a-62c5d7dca553',
    'https://firebasestorage.googleapis.com/v0/b/fluffy-paw-8e7c1.appspot.com/o/images%2F98e9271d-5c7a-4119-8ade-9660395e3773_Screenshot%202024-12-04%20at%2002.13.54.png?alt=media&token=914bc783-4ac3-4a0d-a195-19e94e557593',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => _loadData());

    // Thiết lập timer cho banner
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentBannerIndex < bannerImages.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {
      _showScrollToTop = _scrollController.offset > 200;
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      await ref.read(storeController.notifier).getRecommendedServices();
    } catch (e) {
      debugPrint('Error loading recommended services: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerController.dispose();
    _bannerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dịch vụ nổi bật'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer(
          builder: (context, ref, child) {
            final recommendedServices =
                ref.watch(storeController.notifier).recommendedServices;
            final isLoading = ref.watch(storeController);

            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (recommendedServices == null || recommendedServices.isEmpty) {
              return Center(
                child: Text('Không có dịch vụ được đề xuất'),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildBanner(),
                      SizedBox(height: 24.h),
                      _buildServiceTypeFilter(),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Các dịch vụ phù hợp với bạn',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                _buildServiceGrid(), // Chỉ cần gọi method này
                SliverPadding(padding: EdgeInsets.only(bottom: 20.h)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(Icons.arrow_upward),
              backgroundColor: colors(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildServiceTypeFilter() {
    final serviceTypes = ref.watch(storeController.notifier).petTypes;

    if (serviceTypes == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh mục',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreServiceListLayout(
                        serviceTypeId:
                            _selectedServiceTypeId ?? serviceTypes[0].id,
                        serviceTypeName: _selectedServiceTypeId != null
                            ? serviceTypes
                                .firstWhere(
                                    (t) => t.id == _selectedServiceTypeId)
                                .name
                            : serviceTypes[0].name,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: colors(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: serviceTypes.length,
            itemBuilder: (context, index) {
              final type = serviceTypes[index];
              final isSelected = _selectedServiceTypeId == type.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedServiceTypeId == type.id) {
                      _selectedServiceTypeId =
                          null; // Unselect if already selected
                    } else {
                      _selectedServiceTypeId = type.id;
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors(context).primaryColor
                        : colors(context).primaryColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colors(context).primaryColor!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      type.name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : colors(context).primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return Consumer(
      builder: (context, ref, child) {
        final recommendedServices =
            ref.watch(storeController.notifier).recommendedServices;

        if (recommendedServices == null || recommendedServices.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Không có dịch vụ được đề xuất'),
            ),
          );
        }

        // Filter services based on selected type
        final filteredServices = _selectedServiceTypeId != null
            ? recommendedServices
                .where((s) => s.serviceTypeId == _selectedServiceTypeId)
                .toList()
            : recommendedServices;

        if (filteredServices.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Không có dịch vụ nào trong danh mục này'),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.w,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = filteredServices[index];
                return _buildServiceCard(service);
              },
              childCount: filteredServices.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: NetworkImage(bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index
                        ? colors(context).primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(StoreServiceModel service) {
    return Container(
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
              // Image section with fixed height
              SizedBox(
                height: 120.h,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    service.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          size: 30.sp,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Content section with fixed padding
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service type tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors(context).primaryColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          service.serviceTypeName,
                          style: TextStyle(
                            color: colors(context).primaryColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Service name
                      Expanded(
                        child: Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rating and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                service.totalRating.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${NumberFormat.decimalPattern().format(service.cost)}',
                            style: TextStyle(
                              color: colors(context).primaryColor,
                              fontSize: 12.sp,
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
}

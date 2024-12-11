import 'package:fluffypawuser/components/custom_search_field.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/pet/components/pet_card.dart';
import 'package:fluffypawuser/views/profile/components/earning_history_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PetListLayout extends ConsumerStatefulWidget {
  const PetListLayout({super.key});

  @override
  ConsumerState<PetListLayout> createState() => _PetListLayoutState();
}

class _PetListLayoutState extends ConsumerState<PetListLayout> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(petController.notifier).getPetList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  List<PetModel> _filterPets(List<PetModel> pets, String query) {
    if (query.isEmpty) return pets;
    
    final lowercaseQuery = query.toLowerCase().trim();
    return pets.where((pet) => 
      pet.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    final padding = MediaQuery.of(context).padding;
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: padding.top),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  _buildAppBar(context),
                  buildHeader(context: context),
                ],
              ),
            ),
            Expanded(child: buildBody()),
          ],
        ),
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Text(
              S.of(context).myPets,
              style: AppTextStyle(context).title,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget buildHeader({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).searchYourPet,
            style: AppTextStyle(context).bodyText.copyWith(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
          Gap(10.h),
          SizedBox(
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: CustomSearchField(
                    name: 'searchPet',
                    hintText: S.of(context).searchByName,
                    textInputType: TextInputType.text,
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value!;
                      });
                    },
                    widget: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : const SizedBox(),
                  ),
                ),
                Gap(5.w),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<CircleBorder>(
                      const CircleBorder(),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColor.violetColor),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(10.0),
                    ),
                  ),
                  onPressed: () {
                    context.nav.pushNamed(Routes.selectPetType);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: AppColor.whiteColor,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    return ref.watch(petController)
        ? const EarningHistoryShimmerWidget()
        : AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                searchController.clear();
                setState(() {
                  searchQuery = '';
                });
                await ref.read(petController.notifier).getPetList();
              },
              child: FutureBuilder<Box>(
                future: Hive.openBox(AppConstants.petBox),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final petBox = snapshot.data!;
                  final petData = petBox.get(AppConstants.petData, defaultValue: []) as List;
                  final allPets = petData
                      .map((data) => PetModel.fromMap(Map<String, dynamic>.from(data)))
                      .toList();
                  
                  final filteredPets = _filterPets(allPets, searchQuery);

                  if (filteredPets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          Gap(16.h),
                          Text(
                            searchQuery.isEmpty 
                              ? S.of(context).noPetsFound
                              : S.of(context).noMatchingPets,
                            style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                    controller: scrollController,
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];
                      return AnimationConfiguration.staggeredList(
                        duration: const Duration(milliseconds: 500),
                        position: index,
                        child: SlideAnimation(
                          verticalOffset: 50.0.w,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: PetCard(pet: pet),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
  }
}
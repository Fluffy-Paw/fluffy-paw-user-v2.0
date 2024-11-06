import 'package:fluffypawuser/components/custom_button.dart';
import 'package:fluffypawuser/components/custom_search_field.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/pet/components/select_behavior_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class BehaviorCategorySelectLayout extends ConsumerStatefulWidget {
  const BehaviorCategorySelectLayout({Key? key}) : super(key: key);

  @override
  ConsumerState<BehaviorCategorySelectLayout> createState() => 
      _BehaviorCategorySelectLayoutState();
}

class _BehaviorCategorySelectLayoutState
    extends ConsumerState<BehaviorCategorySelectLayout> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load behavior categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petController.notifier).getPetBehavior();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: ref.watch(petController)
              ? SizedBox(
                  height: 50.h,
                  width: 50.w,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : AbsorbPointer(
                  absorbing: ref.watch(selectedBehaviorCategory) == null,
                  child: CustomButton(
                    buttonText: 'Select Behavior Category',
                    buttonColor: ref.watch(selectedBehaviorCategory) != null
                        ? colors(context).primaryColor
                        : AppColor.violet100,
                    onPressed: () {
                      final behaviorCategories = 
                          ref.read(petController.notifier).behaviorCategories;
                      if (behaviorCategories != null) {
                        final selectedCategory = behaviorCategories.firstWhere(
                          (category) => 
                              category.id == ref.watch(selectedBehaviorCategory),
                        );
                        Navigator.pop(context, selectedCategory);
                      }
                    },
                  ),
                ),
        ),
        body: Column(
          children: [
            buildHeader(context: context),
            Flexible(
              flex: 5,
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)
          .copyWith(top: 50.h),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Behavior Category',
                style: AppTextStyle(context).subTitle,
              ),
              IconButton(
                onPressed: () {
                  context.nav.pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Gap(10.h),
          CustomSearchField(
            name: 'searchBehavior',
            hintText: S.of(context).searchByName,
            textInputType: TextInputType.text,
            controller: searchController,
            onChanged: (value) {
              if (value!.isEmpty) {
                FocusScope.of(context).unfocus();
                ref.read(petController.notifier).getPetBehavior();
              }
            },
            widget: IconButton(
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  ref.read(petController.notifier).getPetBehavior();
                }
              },
              icon: Icon(
                Icons.search,
                size: 30.sp,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    final behaviorCategories = 
        ref.watch(petController.notifier).behaviorCategories ?? [];
    return behaviorCategories.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                searchController.clear();
                ref.read(selectedBehaviorCategory.notifier).state = null;
                ref.read(petController.notifier).getPetBehavior();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                itemCount: behaviorCategories.length,
                itemBuilder: (context, index) {
                  final category = behaviorCategories[index];
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 50.0.w,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: SelectBehaviorCategoryCard(
                            behaviorCategory: category,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
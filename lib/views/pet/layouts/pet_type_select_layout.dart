import 'package:fluffypawuser/components/custom_button.dart';
import 'package:fluffypawuser/components/custom_search_field.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:fluffypawuser/views/pet/components/select_pet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class PetTypeSelectLayout extends ConsumerStatefulWidget {
  final int pettype; // Receive pettype from CreatePetLayout
  const PetTypeSelectLayout({Key? key, required this.pettype}) : super(key: key);

  @override
  ConsumerState<PetTypeSelectLayout> createState() => _PetTypeSelectLayoutState();
}

class _PetTypeSelectLayoutState extends ConsumerState<PetTypeSelectLayout> {
  final TextEditingController petTypeSearchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load pet type data based on pettype value from CreatePetLayout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petController.notifier).getPetType(widget.pettype);
    });
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !ref.watch(petController)) {
      ref.read(petController.notifier).getPetType(widget.pettype);
    }
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
                  absorbing: ref.watch(selectedPetType) == null ? true : false,
                  child: CustomButton(
  buttonText: S.of(context).selectPetType,
  buttonColor: ref.watch(selectedPetType) != null
      ? colors(context).primaryColor
      : AppColor.violet100,
  onPressed: () {
    if (ref.watch(selectedPetType) != null) {
      // Lấy pet type được chọn từ petController
      final petTypes = ref.read(petController.notifier).petTypes;
      if (petTypes != null) {
        final selectedPetTypeData = petTypes.firstWhere(
          (type) => type.id == ref.watch(selectedPetType),
        );
        
        // Trả về id và name của pet type đã chọn
        Navigator.pop(context, selectedPetTypeData);
      }
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
                'Select a Pet Type',
                style: AppTextStyle(context).subTitle,
              ),
              Consumer(builder: (context, ref, _) {
                return IconButton(
                  onPressed: () {
                    context.nav.pop();
                  },
                  icon: const Icon(Icons.close),
                );
              })
            ],
          ),
          Gap(10.h),
          CustomSearchField(
            name: 'searchPetType',
            hintText: S.of(context).searchByName,
            textInputType: TextInputType.text,
            controller: petTypeSearchController,
            onChanged: (value) {
              if (value!.isEmpty) {
                FocusScope.of(context).unfocus();
                ref.read(petController.notifier).getPetType(widget.pettype);
              }
            },
            widget: IconButton(
              onPressed: () {
                if (petTypeSearchController.text.isNotEmpty) {
                  ref.read(petController.notifier).getPetType(widget.pettype);
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
    final petTypeList = ref.watch(petController.notifier).petTypes ?? [];
    return petTypeList.isEmpty
        ? const CircularProgressIndicator()
        : AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                petTypeSearchController.clear();
                ref.read(selectedPetType.notifier).state = null;
                ref.read(petController.notifier).getPetType(widget.pettype);
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                itemCount: petTypeList.length,
                itemBuilder: (context, index) {
                  final petType = petTypeList[index];
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 50.0.w,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: SelectPetTypeCard(
                            petType: petType, // Pass each pet type to the card
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
class SelectedPetType {
  final int id;
  final String name;

  SelectedPetType({required this.id, required this.name});
}

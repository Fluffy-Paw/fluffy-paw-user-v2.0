import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/config/theme.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/utils/context_less_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowGenderMenu extends ConsumerWidget {
  ShowGenderMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 0.h),
          itemBuilder: (context, index) => ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.0),
            minVerticalPadding: 0.0,
            onTap: () {
              context.nav.pop();
              ref.read(selectedGender.notifier).state = gender[index];
              ref.read(genderProvider).text = gender[index];
            },
            title: Text(
              gender[index],
              style: AppTextStyle(context).subTitle,
            ),
            trailing: Radio(
              value: gender[index],
              groupValue: ref.watch(selectedGender.notifier).state,
              onChanged: (String? gender) {
                ref.read(selectedGender.notifier).state = gender ?? '';
              },
            ),
          ),
          separatorBuilder: ((context, index) => Divider(
                thickness: 1.0,
                color: colors(context).bodyTextColor!.withOpacity(0.5),
              )),
          itemCount: gender.length,
        ),
      ],
    );
  }

  final List<String> gender = ['Male', 'Female', 'Other'];
}

import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GlobalFunction {
  GlobalFunction._();
  static Future<void> datePicker({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    ).then((selectedDate) {
      ref.read(dateOfBirthProvider).text = formateDate(selectedDate!);
    });
  }

  static String formateDate(DateTime date) {
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy', 'en');
    return dateFormatter.format(date);
  }

  static Future<void> pickImageFromCamera({required WidgetRef ref}) async {
    final picker = ImagePicker();
    await picker.pickImage(source: ImageSource.camera).then((imageFile) {
      if (imageFile != null) {
        ref.read(selectedUserProfileImage.notifier).state = imageFile;
      }
    });
  }

  static Future<void> pickImageFromGallery(
      {required WidgetRef ref, required ImageType imageType}) async {
    final picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((imageFile) {
      if (imageFile != null) {
        switch (imageType) {
          case ImageType.userProfile:
            ref.read(selectedUserProfileImage.notifier).state = imageFile;
            break;
          case ImageType.shopLogo:
            ref.read(selectedShopLogo.notifier).state = imageFile;
            break;
          case ImageType.shopBanner:
            ref.read(selectedShopBanner.notifier).state = imageFile;
            break;
        }
      }
    });
  }

  // static String getDashboardSummeryLocalizationText(
  //     {required String text, required BuildContext context}) {
  //   switch (text) {
  //     case "Today's Order":
  //       return S.of(context).todaysOrder;
  //     case "Ongoing Order":
  //       return S.of(context).ongoingOrder;
  //     case "Today's Earnings":
  //       return S.of(context).todaysEarnings;
  //     default:
  //       return S.of(context).earndThisMonth;
  //   }
  // }

//   static String getOrderStatusLocalizationText({
//   required String status,
//   required BuildContext context,
// }) {
//   switch (status) {
//     case "Accepted":
//       return S.of(context).accepted;
//     case "Pending":
//       return S.of(context).pending;
//     case "Canceled":
//       return S.of(context).canceled;
//     case "Denied":
//       return S.of(context).denied;
//     case "OverTime":
//       return S.of(context).overTime;
//     case "Ended":
//       return S.of(context).ended;
//     default:
//       return S.of(context).cancelled;
//   }
// }


  // static String getRidersStatusLocalizationText(
  //     {required String status, required BuildContext context}) {
  //   switch (status) {
  //     case 'Active':
  //       return S.of(context).active;
  //     default:
  //       return S.of(context).inActive;
  //   }
  // }

  static String getPaymentStatusLocalizationText(
      {required String status, required BuildContext context}) {
    switch (status) {
      case 'Cash Payment':
        return S.of(context).cod;
      default:
        return S.of(context).payos;
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static void showCustomSnackbar({
    required String message,
    required bool isSuccess,
    bool isTop = false,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16.r,
        ),
      ),
      dismissDirection:
      isTop ? DismissDirection.startToEnd : DismissDirection.down,
      backgroundColor: isSuccess ? AppColor.violetColor : AppColor.redColor,
      content: Text(message),
      margin: isTop
          ? EdgeInsets.only(
        bottom: MediaQuery.of(navigatorKey.currentState!.context)
            .size
            .height -
            160,
        right: 20,
        left: 20,
      )
          : null,
    );
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      snackBar,
    );
  }

  static void changeStatusBarTheme({required isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  static String errorText(
      {required String fieldName, required BuildContext context}) {
    return '$fieldName ${S.of(context).validationMessage}';
  }

  static String? firstNameValidator(
      {required String value,
        required String hintText,
        required BuildContext context}) {
    if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    } else if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? lastNameNameValidator(
      {required String value,
        required String hintText,
        required BuildContext context}) {
    if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    } else if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? phoneValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (value.length != 11) {
      return 'Please enter a valid $hintText with exactly 11 digits';
    }
    return null;
  }

  static String? emailValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid $hintText';
    }

    return null;
  }

  static String? weightValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }

    final RegExp weightRegex = RegExp(r'^\d*\.?\d{0,2}$');
    if (!weightRegex.hasMatch(value)) {
      return '${S.of(context).weight} không hợp lệ';
    }

    final double weight = double.parse(value);
    if (weight <= 0 || weight > 100) {
      return '${S.of(context).weight} phải từ 0 đến 100kg';
    }

    return null;
  }

  static String? defaultValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? shopNameValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    }
    return null;
  }

  static String? orderPrefixCodeValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? dateOfBirthValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? shopDesValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? passwordValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (value.length < 6) {
      return 'Please enter a valid $hintText with at least 6 characters';
    }

    return null;
  }

  static bool containsNumber(String input) {
    final RegExp numericRegex = RegExp(r'\d');
    return numericRegex.hasMatch(input);
  }

  static Color getStatusCardColor({required String status}) {
  switch (status) {
    case 'Accepted':
      return AppColor.delivered; // Màu của trạng thái "Accepted"
    case 'Pending':
      return AppColor.pending; // Màu của trạng thái "Pending"
    case 'Canceled':
      return AppColor.redColor; // Màu của trạng thái "Canceled"
    case 'Denied':
      return AppColor.redColor; // Màu của trạng thái "Denied"
    case 'OverTime':
      return Colors.orange; // Màu của trạng thái "OverTime"
    case 'Ended':
      return Colors.green; // Màu của trạng thái "Ended"
    default:
      return AppColor.redColor; // Trạng thái mặc định nếu không khớp
  }
}


  static void clearControllers({required WidgetRef ref}) {
    ref.refresh(firstNameProvider);
    // ref.refresh(lastNameProvider);
    // ref.refresh(phoneProvider);
    //ref.refresh(emailProvider);
    ref.refresh(genderProvider);
    // ref.refresh(passwordProvider);
    // ref.refresh(confirmPassProvider);
    // ref.refresh(shopNameProvider);
    // ref.refresh(orderPrefixCodeProvider);
    // ref.refresh(shopDescriptionProvider);
    
    // ref.refresh(vehcleTypeProvider);
    // ref.refresh(drivingLicenceProvider);
    ref.refresh(dateOfBirthProvider);
    ref.refresh(selectedUserProfileImage);
    ref.refresh(selectedShopLogo);
    ref.refresh(selectedShopBanner);
    ref.refresh(allergyProvider);
    ref.refresh(behaviorCategoryProvider);
    ref.refresh(isNeuterProvider);
    ref.refresh(petTypeProvider);
    ref.refresh(weightProvider);
  }

  static String numberLocalization(dynamic number) {
    dynamic local =
    Hive.box(AppConstants.appSettingsBox).get(AppConstants.appLocal);
    double parsedNumber =
        double.tryParse(number.toString().replaceAll(',', '')) ?? 0.0;
    final NumberFormat numberFormat =
    NumberFormat.decimalPattern(local['value']);
    return numberFormat.format(parsedNumber);
  }

  static String stringLocalization(String inputString, BuildContext context) {
    dynamic local =
    Hive.box(AppConstants.appSettingsBox).get(AppConstants.appLocal);
    final formattedString =
    NumberFormat.simpleCurrency(locale: local).format(0);

    return '$inputString $formattedString';
  }
}

enum ImageType {
  userProfile,
  shopLogo,
  shopBanner,
}

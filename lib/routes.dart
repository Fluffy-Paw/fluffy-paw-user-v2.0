import 'package:fluffypawuser/models/booking/booking_data_model.dart';
import 'package:fluffypawuser/views/authentication/login_view.dart';
import 'package:fluffypawuser/views/authentication/phone_view.dart';
import 'package:fluffypawuser/views/booking/layouts/booking_history_layout.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/bottom_navigation_bar_view.dart';
import 'package:fluffypawuser/views/forget_password/ForgetPasswordScreen.dart';
import 'package:fluffypawuser/views/home_screen/layouts/home_layout.dart';
import 'package:fluffypawuser/views/notification/notification_view.dart';
import 'package:fluffypawuser/views/pet/add_vaccine_view.dart';
import 'package:fluffypawuser/views/pet/create_pet_view.dart';
import 'package:fluffypawuser/views/pet/pet_detail_view.dart';
import 'package:fluffypawuser/views/pet/pet_list_view.dart';
import 'package:fluffypawuser/views/pet/pet_type_view.dart';
import 'package:fluffypawuser/views/pet/vaccine_detail_view.dart';
import 'package:fluffypawuser/views/profile/user_profile_view.dart';
import 'package:fluffypawuser/views/splash_screen/splash_view.dart';
import 'package:fluffypawuser/views/store/choose_pet_for_booking_view.dart';
import 'package:fluffypawuser/views/store/store_detail_view.dart';
import 'package:fluffypawuser/views/store/store_list_view.dart';
import 'package:fluffypawuser/views/store/store_service_by_service_type_view.dart';
import 'package:fluffypawuser/views/wallet/top_up_view.dart';
import 'package:fluffypawuser/views/wallet/wallet_view.dart';
import 'package:fluffypawuser/views/wallet/withdraw_view.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  Routes._();
  static const splash = '/';
  static const login = '/login';
  static const core = '/core';
  static const selectPetType = '/selectPetType';
  static const createPet = '/createPet';
  static const petList = "/petList";
  static const petDetail = "/petDetail";
  static const storeListByService = "/storeListByService";
  static const storeDetail = "/storeDetail";
  static const choosePetForBooking = "/choosePetForBooking";
  static const addVaccine = "/addVaccine";
  static const vaccineDetail = "/vaccineDetail";
  static const wallet = "/wallet";
  static const topUp = "/topUp";
  static const withdraw = "/withdraw";
  static const bookingHistory = "/bookingHistory";
  static const register = "/register";
  static const profile = "/profile";
  static const notification = "/notification";
  static const storeServiceByType = "/storeServiceByType";
  static const String forgotPassword = '/forgot-password';
}

Route generatedRoutes(RouteSettings settings) {
  Widget child;

  switch (settings.name) {
    case Routes.splash:
      child = const SplashView();
      break;
    case Routes.notification:
      child = const NotificationView();
    case Routes.login:
      child = const LoginView();
      break;
    case Routes.profile:
      child = const UserProfileView();
      break;
    case Routes.register:
      child = const PhoneView();
      break;
    case Routes.forgotPassword:
      return MaterialPageRoute(
        builder: (_) => const ForgetPasswordScreen(),
      );
    case Routes.selectPetType:
      child = const PetTypeView();
      break;
    case Routes.wallet:
      child = const WalletView();
      break;
    case Routes.withdraw:
      child = const WithdrawView();
      break;
    case Routes.bookingHistory:
      child = const BookingHistoryLayout();
      break;
    case Routes.topUp:
      child = const TopUpView();
      break;
    case Routes.petList:
      child = const PetListView();
      break;
    case Routes.choosePetForBooking:
      final args = settings.arguments as ChoosePetForBookingArguments;
      child = ChoosePetForBookingView(
        bookingData: args.bookingData,
      );
      break;
    case Routes.createPet:
      final id = settings.arguments as int;
      child = CreatePetView(id: id);
      break;
    case Routes.addVaccine:
      final id = settings.arguments as int;
      child = AddVaccineView(id: id);
      break;
    case Routes.vaccineDetail:
      final id = settings.arguments as int;
      child = VaccineDetailView(id: id);
      break;
    case Routes.storeDetail:
      final args = settings.arguments as Map<String, dynamic>;
      final serviceTypeId = args['serviceTypeId'] as int;
      final isFromBookingScreen = args['isFromBookingScreen'] as int?;
      child = StoreDetailView(
        serviceTypeId: serviceTypeId,
        isFromBookingScreen: isFromBookingScreen,
      );
      break;
    case Routes.storeListByService:
      final args = settings.arguments as StoreListArguments;
      child = StoreListView(
        serviceTypeId: args.serviceTypeId,
        serviceTypeName: args.serviceTypeName,
      );
      break;
    case Routes.storeServiceByType:
      final args = settings.arguments as StoreListArguments;
      child = StoreServiceByServiceTypeView(
        serviceTypeId: args.serviceTypeId,
        serviceTypeName: args.serviceTypeName,
      );
      break;
    case Routes.petDetail:
      final id = settings.arguments as int;
      child = PetDetailView(petId: id);
      break;
    case Routes.core:
      child = const BottomNavigationBarView();
      break;
    default:
      throw Exception('Invalid route: ${settings.name}');
  }
  debugPrint('Route: ${settings.name}');

  return PageTransition(
    child: child,
    type: PageTransitionType.fade,
    settings: settings,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
}

class ChoosePetForBookingArguments {
  final BookingDataModel bookingData;

  ChoosePetForBookingArguments({
    required this.bookingData,
  });
}

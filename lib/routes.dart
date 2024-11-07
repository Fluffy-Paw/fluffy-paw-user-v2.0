import 'package:fluffypawuser/views/authentication/login_view.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/bottom_navigation_bar_view.dart';
import 'package:fluffypawuser/views/home_screen/layouts/home_layout.dart';
import 'package:fluffypawuser/views/pet/create_pet_view.dart';
import 'package:fluffypawuser/views/pet/pet_detail_view.dart';
import 'package:fluffypawuser/views/pet/pet_list_view.dart';
import 'package:fluffypawuser/views/pet/pet_type_view.dart';
import 'package:fluffypawuser/views/splash_screen/splash_view.dart';
import 'package:fluffypawuser/views/store/choose_pet_for_booking_view.dart';
import 'package:fluffypawuser/views/store/layouts/choose_pet_for_booking_layout.dart';
import 'package:fluffypawuser/views/store/layouts/store_list_by_service_layout.dart';
import 'package:fluffypawuser/views/store/store_detail_view.dart';
import 'package:fluffypawuser/views/store/store_list_view.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Routes{
  Routes._();
  static const splash = '/';
  static const login = '/login';
  static const core = '/core';
  static const selectPetType = '/selectPetType';
  static const createPet = '/createPet';
  static const petList ="/petList";
  static const petDetail ="/petDetail";
  static const storeListByService ="/storeListByService";
  static const storeDetail ="/storeDetail";
  static const choosePetForBooking ="/choosePetForBooking";
  
}
Route generatedRoutes(RouteSettings settings){
  Widget child;

  switch(settings.name){
    case Routes.splash:
      child = const SplashView();
      break;
    case Routes.login:
      child = const LoginView();
      break;
    case Routes.selectPetType:
      child = const PetTypeView();
      break;
    case Routes.petList:
      child = const PetListView();
      break;
    case Routes.choosePetForBooking:
      final serviceTypeId = settings.arguments as int;
      child = ChoosePetForBookingView(serviceTypeId: serviceTypeId);
      break;
    case Routes.createPet:
      final id = settings.arguments as int;
      child = CreatePetView(id: id);
      break;
    case Routes.storeDetail:
      final id = settings.arguments as int;
      child = StoreDetailView(serviceTypeId: id);
      break;
    case Routes.storeListByService:
      // Handle StoreListArguments
      final args = settings.arguments as StoreListArguments;
      child = StoreListView(
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
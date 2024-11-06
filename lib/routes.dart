import 'package:fluffypawuser/views/authentication/login_view.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/bottom_navigation_bar_view.dart';
import 'package:fluffypawuser/views/pet/create_pet_view.dart';
import 'package:fluffypawuser/views/pet/pet_detail_view.dart';
import 'package:fluffypawuser/views/pet/pet_list_view.dart';
import 'package:fluffypawuser/views/pet/pet_type_view.dart';
import 'package:fluffypawuser/views/splash_screen/splash_view.dart';
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
    case Routes.createPet:
      final id = settings.arguments as int;
      child = CreatePetView(id: id);
    case Routes.petDetail:
      final id = settings.arguments as int;
      child = PetDetailView(petId: id);
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
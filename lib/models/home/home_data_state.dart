import 'package:fluffypawuser/models/pet/pet_model.dart';
import 'package:fluffypawuser/models/pet/service_type_model.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';

class HomeState {
  final List<PetModel> pets;
  final UserModel? userInfo;
  final List<ServiceTypeModel> serviceTypes;
  final bool isLoading;
  final DateTime? lastUpdated;
  final String? error;

  HomeState({
    this.pets = const [],
    this.userInfo,
    this.serviceTypes = const [],
    this.isLoading = true,
    this.lastUpdated,
    this.error,
  });

  HomeState copyWith({
    List<PetModel>? pets,
    UserModel? userInfo,
    List<ServiceTypeModel>? serviceTypes,
    bool? isLoading,
    DateTime? lastUpdated,
    String? error,
  }) {
    return HomeState(
      pets: pets ?? this.pets,
      userInfo: userInfo ?? this.userInfo,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error ?? this.error,
    );
  }
}
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/controllers/pet/pet_controller.dart';
import 'package:fluffypawuser/controllers/profile/profile_controller.dart';
import 'package:fluffypawuser/controllers/store/store_controller.dart';
import 'package:fluffypawuser/models/home/home_data_state.dart';
import 'package:fluffypawuser/models/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeController extends StateNotifier<HomeState> {
  final Ref ref;
  static const Duration cacheDuration = Duration(minutes: 5);
  late final PetController _petController;
  late final ProfileController _profileController;
  late final StoreController _storeController;

  HomeController(this.ref) : super(HomeState()) {
    _petController = ref.read(petController.notifier);
    _profileController = ref.read(profileController.notifier);
    _storeController = ref.read(storeController.notifier);
    initializeData();
  }

  Future<void> _loadCachedData() async {
    try {
      if (Hive.isBoxOpen(AppConstants.userBox)) {
        final userBox = Hive.box(AppConstants.userBox);
        final userData = userBox.get(AppConstants.userData);
        if (userData != null) {
          final userInfo = UserModel.fromMap(Map<String, dynamic>.from(userData));
          state = state.copyWith(userInfo: userInfo);
        }
      }

      if (Hive.isBoxOpen(AppConstants.petBox)) {
        final pets = ref.read(hiveStoreService).getPetInfo();
        if (pets.isNotEmpty) {
          state = state.copyWith(pets: pets);
        }
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _fetchFreshData() async {
    try {
      // Fetch user data
      await _profileController.getAccountDetails();
      if (Hive.isBoxOpen(AppConstants.userBox)) {
        final userBox = Hive.box(AppConstants.userBox);
        final userData = userBox.get(AppConstants.userData);
        if (userData != null) {
          final userInfo = UserModel.fromMap(Map<String, dynamic>.from(userData));
          state = state.copyWith(userInfo: userInfo);
        }
      }

      // Fetch pet data
      await _petController.getPetList();
      final pets = ref.read(hiveStoreService).getPetInfo();
      state = state.copyWith(pets: pets);

      // Fetch service types
      if (state.serviceTypes.isEmpty) {
        await _storeController.getServiceTypeList();
        final serviceTypes = _storeController.petTypes ?? [];
        state = state.copyWith(serviceTypes: serviceTypes);
      }
    } catch (e) {
      debugPrint('Error fetching fresh data: $e');
    }
  }

  Future<void> initializeData() async {
    if (!shouldRefreshData()) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Load cached data first
      await _loadCachedData();
      
      // Then fetch fresh data
      await _fetchFreshData();
    } catch (e) {
      debugPrint('Error initializing home data: $e');
    } finally {
      state = state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    }
  }

  bool shouldRefreshData() {
    if (state.lastUpdated == null) return true;
    return DateTime.now().difference(state.lastUpdated!) > cacheDuration;
  }

  Future<void> refreshData({bool force = false}) async {
    if (!force && !shouldRefreshData()) return;

    state = state.copyWith(isLoading: true);
    try {
      await _fetchFreshData();
    } finally {
      state = state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    }
  }
}
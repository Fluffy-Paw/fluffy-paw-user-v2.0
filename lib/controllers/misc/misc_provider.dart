import 'package:fluffypawuser/controllers/home/home_controller.dart';
import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/models/home/home_data_state.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final selectedUserProfileImage = StateProvider<XFile?>((ref) => null);
final selectedShopLogo = StateProvider<XFile?>((ref) => null);
final selectedShopBanner = StateProvider<XFile?>((ref) => null);
final obscureText1 = StateProvider<bool>((ref) => true);
final selectedIndexProvider = StateProvider<int>((ref) => 0);
final selectedGender = StateProvider<String>((ref) => '');
final selectedPetType = StateProvider<int?>((ref) => null);
final selectedBehaviorCategory = StateProvider<int?>((ref) => null);
final hasNewBookingProvider = StateProvider<bool>((ref) => false);
final bottomTabControllerProvider =
Provider<PageController>((ref) => PageController());

final firstNameProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});
final ridersFormKey = Provider<GlobalKey<FormBuilderState>>(
    (ref) => GlobalKey<FormBuilderState>());
final dateOfBirthProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});
final descriptionProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});
final genderProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final allergyProvider = Provider<TextEditingController>((ref) {
 final controller = TextEditingController();
  return controller;
});

final behaviorCategoryProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});

final isNeuterProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: 'false'); // Mặc định là false
  ref.onDispose(() => controller.dispose());
  return controller;
});

final petTypeProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});

final weightProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});

final microchipNumberProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  return controller;
});
final selectedFilterProvider = StateProvider<NotificationType?>((ref) => null);

final filteredNotificationsProvider = Provider<List<PetNotification>>((ref) {
  final state = ref.watch(notificationControllerProvider);
  final filter = ref.watch(selectedFilterProvider);
  
  if (filter == null) return state.notifications;
  return state.notifications.where((n) => n.type == filter).toList();
});

final unreadCountProvider = Provider.family<int, NotificationType?>((ref, type) {
  return ref.watch(notificationControllerProvider.notifier).getUnreadCount(type);
});

final notificationCountProvider = Provider.family<int, NotificationType?>((ref, type) {
  return ref.watch(notificationControllerProvider.notifier).getNotificationCount(type);
});
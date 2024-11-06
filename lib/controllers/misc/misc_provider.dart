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
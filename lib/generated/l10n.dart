// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Book a date`
  String get book_date {
    return Intl.message(
      'Book a date',
      name: 'book_date',
      desc: '',
      args: [],
    );
  }

  /// `No pets available`
  String get no_pets_available {
    return Intl.message(
      'No pets available',
      name: 'no_pets_available',
      desc: '',
      args: [],
    );
  }

  /// `Availability`
  String get availability {
    return Intl.message(
      'Availability',
      name: 'availability',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get services {
    return Intl.message(
      'Services',
      name: 'services',
      desc: '',
      args: [],
    );
  }

  /// `Prices are estimative and the payment will be made at the location.`
  String get price_notice {
    return Intl.message(
      'Prices are estimative and the payment will be made at the location.',
      name: 'price_notice',
      desc: '',
      args: [],
    );
  }

  /// `Select Payment Method`
  String get select_payment_method {
    return Intl.message(
      'Select Payment Method',
      name: 'select_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `PayOS`
  String get payos {
    return Intl.message(
      'PayOS',
      name: 'payos',
      desc: '',
      args: [],
    );
  }

  /// `COD`
  String get cod {
    return Intl.message(
      'COD',
      name: 'cod',
      desc: '',
      args: [],
    );
  }

  /// `Add Note`
  String get add_note {
    return Intl.message(
      'Add Note',
      name: 'add_note',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Booking`
  String get confirm_booking {
    return Intl.message(
      'Confirm Booking',
      name: 'confirm_booking',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one pet`
  String get select_pet_prompt {
    return Intl.message(
      'Please select at least one pet',
      name: 'select_pet_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Booking success`
  String get booking_success {
    return Intl.message(
      'Booking success',
      name: 'booking_success',
      desc: '',
      args: [],
    );
  }

  /// `230 reviews`
  String get review_count {
    return Intl.message(
      '230 reviews',
      name: 'review_count',
      desc: '',
      args: [],
    );
  }

  /// `No services available`
  String get no_services_available {
    return Intl.message(
      'No services available',
      name: 'no_services_available',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Hours:`
  String get hours {
    return Intl.message(
      'Hours:',
      name: 'hours',
      desc: '',
      args: [],
    );
  }

  /// `Add to contacts`
  String get add_to_contacts {
    return Intl.message(
      'Add to contacts',
      name: 'add_to_contacts',
      desc: '',
      args: [],
    );
  }

  /// `Chat with Shop`
  String get chat_with_shop {
    return Intl.message(
      'Chat with Shop',
      name: 'chat_with_shop',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message(
      'Service',
      name: 'service',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message(
      'Message',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Xin chào`
  String get hello {
    return Intl.message(
      'Xin chào',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Most Used Services!`
  String get most_used_services {
    return Intl.message(
      'Most Used Services!',
      name: 'most_used_services',
      desc: '',
      args: [],
    );
  }

  /// `No stores available`
  String get no_stores_available {
    return Intl.message(
      'No stores available',
      name: 'no_stores_available',
      desc: '',
      args: [],
    );
  }

  /// `Brand:`
  String get brand {
    return Intl.message(
      'Brand:',
      name: 'brand',
      desc: '',
      args: [],
    );
  }

  /// `Phone:`
  String get phone {
    return Intl.message(
      'Phone:',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Country:`
  String get country {
    return Intl.message(
      'Country:',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `City:`
  String get city {
    return Intl.message(
      'City:',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `Loading data...`
  String get loading_data {
    return Intl.message(
      'Loading data...',
      name: 'loading_data',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get log_in {
    return Intl.message(
      'Log In',
      name: 'log_in',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Username`
  String get enter_username {
    return Intl.message(
      'Enter Your Username',
      name: 'enter_username',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Password`
  String get enter_password {
    return Intl.message(
      'Enter Your Password',
      name: 'enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get remember_me {
    return Intl.message(
      'Remember me',
      name: 'remember_me',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgot_password {
    return Intl.message(
      'Forgot password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Email and password cannot be empty`
  String get empty_email_password_error {
    return Intl.message(
      'Email and password cannot be empty',
      name: 'empty_email_password_error',
      desc: '',
      args: [],
    );
  }

  /// `Login failed. Please try again.`
  String get login_failure_message {
    return Intl.message(
      'Login failed. Please try again.',
      name: 'login_failure_message',
      desc: '',
      args: [],
    );
  }

  /// `Fluffy Paw`
  String get fluffy_paw {
    return Intl.message(
      'Fluffy Paw',
      name: 'fluffy_paw',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get no_account {
    return Intl.message(
      'Don\'t have an account?',
      name: 'no_account',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `25 September`
  String get date_25_september {
    return Intl.message(
      '25 September',
      name: 'date_25_september',
      desc: '',
      args: [],
    );
  }

  /// `15 September`
  String get date_15_september {
    return Intl.message(
      '15 September',
      name: 'date_15_september',
      desc: '',
      args: [],
    );
  }

  /// `Your checkout is successful, product is on the way`
  String get checkout_success {
    return Intl.message(
      'Your checkout is successful, product is on the way',
      name: 'checkout_success',
      desc: '',
      args: [],
    );
  }

  /// `Appointment request accepted`
  String get appointment_accepted {
    return Intl.message(
      'Appointment request accepted',
      name: 'appointment_accepted',
      desc: '',
      args: [],
    );
  }

  /// `Vaccinate your pet timely`
  String get vaccinate_reminder {
    return Intl.message(
      'Vaccinate your pet timely',
      name: 'vaccinate_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Fluffy Paw!`
  String get welcome_message {
    return Intl.message(
      'Welcome to Fluffy Paw!',
      name: 'welcome_message',
      desc: '',
      args: [],
    );
  }

  /// `Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore`
  String get lorem_text {
    return Intl.message(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore',
      name: 'lorem_text',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get get_started {
    return Intl.message(
      'Get Started',
      name: 'get_started',
      desc: '',
      args: [],
    );
  }

  /// `Pet Form`
  String get pet_form {
    return Intl.message(
      'Pet Form',
      name: 'pet_form',
      desc: '',
      args: [],
    );
  }

  /// `Bạn muốn thêm?`
  String get add_pet_option {
    return Intl.message(
      'Bạn muốn thêm?',
      name: 'add_pet_option',
      desc: '',
      args: [],
    );
  }

  /// `Dog`
  String get dog {
    return Intl.message(
      'Dog',
      name: 'dog',
      desc: '',
      args: [],
    );
  }

  /// `Cat`
  String get cat {
    return Intl.message(
      'Cat',
      name: 'cat',
      desc: '',
      args: [],
    );
  }

  /// `Loading breed list...`
  String get loading_breed_list {
    return Intl.message(
      'Loading breed list...',
      name: 'loading_breed_list',
      desc: '',
      args: [],
    );
  }

  /// `Could not load breed list. Please try again.`
  String get breed_list_error {
    return Intl.message(
      'Could not load breed list. Please try again.',
      name: 'breed_list_error',
      desc: '',
      args: [],
    );
  }

  /// `Behavior Category`
  String get behavior_category {
    return Intl.message(
      'Behavior Category',
      name: 'behavior_category',
      desc: '',
      args: [],
    );
  }

  /// `No behavior categories available`
  String get no_behavior_categories_available {
    return Intl.message(
      'No behavior categories available',
      name: 'no_behavior_categories_available',
      desc: '',
      args: [],
    );
  }

  /// `Select a behavior category`
  String get select_behavior_category {
    return Intl.message(
      'Select a behavior category',
      name: 'select_behavior_category',
      desc: '',
      args: [],
    );
  }

  /// `Please select a behavior category`
  String get select_behavior_category_validation {
    return Intl.message(
      'Please select a behavior category',
      name: 'select_behavior_category_validation',
      desc: '',
      args: [],
    );
  }

  /// `Pet Name`
  String get pet_name {
    return Intl.message(
      'Pet Name',
      name: 'pet_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pet's name`
  String get enter_pet_name {
    return Intl.message(
      'Please enter pet\'s name',
      name: 'enter_pet_name',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pet's gender`
  String get enter_pet_gender {
    return Intl.message(
      'Please enter pet\'s gender',
      name: 'enter_pet_gender',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pet's weight`
  String get enter_pet_weight {
    return Intl.message(
      'Please enter pet\'s weight',
      name: 'enter_pet_weight',
      desc: '',
      args: [],
    );
  }

  /// `Birth Date (YYYY-MM-DD)`
  String get birth_date {
    return Intl.message(
      'Birth Date (YYYY-MM-DD)',
      name: 'birth_date',
      desc: '',
      args: [],
    );
  }

  /// `Please select pet's birth date`
  String get select_birth_date {
    return Intl.message(
      'Please select pet\'s birth date',
      name: 'select_birth_date',
      desc: '',
      args: [],
    );
  }

  /// `Allergy`
  String get allergy {
    return Intl.message(
      'Allergy',
      name: 'allergy',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pet's allergy information`
  String get enter_allergy {
    return Intl.message(
      'Please enter pet\'s allergy information',
      name: 'enter_allergy',
      desc: '',
      args: [],
    );
  }

  /// `Microchip Number`
  String get microchip_number {
    return Intl.message(
      'Microchip Number',
      name: 'microchip_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pet's microchip number`
  String get enter_microchip_number {
    return Intl.message(
      'Please enter pet\'s microchip number',
      name: 'enter_microchip_number',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a description for the pet`
  String get enter_description {
    return Intl.message(
      'Please enter a description for the pet',
      name: 'enter_description',
      desc: '',
      args: [],
    );
  }

  /// `Is Neutered: `
  String get is_neutered {
    return Intl.message(
      'Is Neutered: ',
      name: 'is_neutered',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Pet added successfully!`
  String get pet_added_successfully {
    return Intl.message(
      'Pet added successfully!',
      name: 'pet_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Error adding pet`
  String get error_adding_pet {
    return Intl.message(
      'Error adding pet',
      name: 'error_adding_pet',
      desc: '',
      args: [],
    );
  }

  /// `Update Vaccine`
  String get update_vaccine {
    return Intl.message(
      'Update Vaccine',
      name: 'update_vaccine',
      desc: '',
      args: [],
    );
  }

  /// `Create New Vaccine`
  String get create_vaccine {
    return Intl.message(
      'Create New Vaccine',
      name: 'create_vaccine',
      desc: '',
      args: [],
    );
  }

  /// `Vaccine Name`
  String get vaccine_name {
    return Intl.message(
      'Vaccine Name',
      name: 'vaccine_name',
      desc: '',
      args: [],
    );
  }

  /// `Vaccine Date`
  String get vaccine_date {
    return Intl.message(
      'Vaccine Date',
      name: 'vaccine_date',
      desc: '',
      args: [],
    );
  }

  /// `Next Vaccine Date`
  String get next_vaccine_date {
    return Intl.message(
      'Next Vaccine Date',
      name: 'next_vaccine_date',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Delete Pet`
  String get delete_pet {
    return Intl.message(
      'Delete Pet',
      name: 'delete_pet',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this pet?`
  String get confirm_delete_pet {
    return Intl.message(
      'Are you sure you want to delete this pet?',
      name: 'confirm_delete_pet',
      desc: '',
      args: [],
    );
  }

  /// `Delete failed`
  String get delete_failed {
    return Intl.message(
      'Delete failed',
      name: 'delete_failed',
      desc: '',
      args: [],
    );
  }

  /// `Delete failed: {error_message}`
  String delete_failed_message(Object error_message) {
    return Intl.message(
      'Delete failed: $error_message',
      name: 'delete_failed_message',
      desc: '',
      args: [error_message],
    );
  }

  /// `Invalid phone number.`
  String get invalid_phone_number {
    return Intl.message(
      'Invalid phone number.',
      name: 'invalid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error_message}`
  String error_message(Object error_message) {
    return Intl.message(
      'Error: $error_message',
      name: 'error_message',
      desc: '',
      args: [error_message],
    );
  }

  /// `Phone number cannot be empty.`
  String get empty_phone_number {
    return Intl.message(
      'Phone number cannot be empty.',
      name: 'empty_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Information`
  String get enter_information {
    return Intl.message(
      'Enter Your Information',
      name: 'enter_information',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Confirm Password`
  String get enter_confirm_password {
    return Intl.message(
      'Enter Confirm Password',
      name: 'enter_confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message(
      'Full Name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Full Name`
  String get enter_full_name {
    return Intl.message(
      'Enter Your Full Name',
      name: 'enter_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Address`
  String get enter_address {
    return Intl.message(
      'Enter Your Address',
      name: 'enter_address',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Email`
  String get enter_email {
    return Intl.message(
      'Enter Your Email',
      name: 'enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get date_of_birth {
    return Intl.message(
      'Date of Birth',
      name: 'date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Select your date of birth`
  String get select_date_of_birth {
    return Intl.message(
      'Select your date of birth',
      name: 'select_date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Select your gender`
  String get select_gender {
    return Intl.message(
      'Select your gender',
      name: 'select_gender',
      desc: '',
      args: [],
    );
  }

  /// `I agree to the Terms and Conditions`
  String get agree_terms_conditions {
    return Intl.message(
      'I agree to the Terms and Conditions',
      name: 'agree_terms_conditions',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get complete {
    return Intl.message(
      'Complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }

  /// `Verify OTP`
  String get verify_otp {
    return Intl.message(
      'Verify OTP',
      name: 'verify_otp',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your OTP`
  String get enter_otp {
    return Intl.message(
      'Enter Your OTP',
      name: 'enter_otp',
      desc: '',
      args: [],
    );
  }

  /// `Enter your OTP sent to {phone}`
  String enter_otp_sent_to(Object phone) {
    return Intl.message(
      'Enter your OTP sent to $phone',
      name: 'enter_otp_sent_to',
      desc: '',
      args: [phone],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Successfully signed in with credential`
  String get signed_in_successfully {
    return Intl.message(
      'Successfully signed in with credential',
      name: 'signed_in_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Error signing in: {error_message}`
  String sign_in_error(Object error_message) {
    return Intl.message(
      'Error signing in: $error_message',
      name: 'sign_in_error',
      desc: '',
      args: [error_message],
    );
  }

  /// `field cannot be empty`
  String get validationMessage {
    return Intl.message(
      'field cannot be empty',
      name: 'validationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Login to Fluffy Paw Platform`
  String get loginTitle {
    return Intl.message(
      'Login to Fluffy Paw Platform',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Explorer`
  String get explorer {
    return Intl.message(
      'Explorer',
      name: 'explorer',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activity {
    return Intl.message(
      'Activity',
      name: 'activity',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message(
      'Payment',
      name: 'payment',
      desc: '',
      args: [],
    );
  }

  /// `Inbox`
  String get inbox {
    return Intl.message(
      'Inbox',
      name: 'inbox',
      desc: '',
      args: [],
    );
  }

  /// `Fluffy Coin`
  String get fluffyCoin {
    return Intl.message(
      'Fluffy Coin',
      name: 'fluffyCoin',
      desc: '',
      args: [],
    );
  }

  /// `open`
  String get open {
    return Intl.message(
      'open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Pet`
  String get pet {
    return Intl.message(
      'Pet',
      name: 'pet',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure, you want to log out of your account?`
  String get logoutDes {
    return Intl.message(
      'Are you sure, you want to log out of your account?',
      name: 'logoutDes',
      desc: '',
      args: [],
    );
  }

  /// `Add new pet`
  String get addPet {
    return Intl.message(
      'Add new pet',
      name: 'addPet',
      desc: '',
      args: [],
    );
  }

  /// `Add Pet`
  String get createNewPet {
    return Intl.message(
      'Add Pet',
      name: 'createNewPet',
      desc: '',
      args: [],
    );
  }

  /// `Avatar is required`
  String get profileImageIsReq {
    return Intl.message(
      'Avatar is required',
      name: 'profileImageIsReq',
      desc: '',
      args: [],
    );
  }

  /// `Add Pet Photo`
  String get addPetPhotoReq {
    return Intl.message(
      'Add Pet Photo',
      name: 'addPetPhotoReq',
      desc: '',
      args: [],
    );
  }

  /// `Pet Name`
  String get petName {
    return Intl.message(
      'Pet Name',
      name: 'petName',
      desc: '',
      args: [],
    );
  }

  /// `Date Of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date Of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Microchip`
  String get microchip {
    return Intl.message(
      'Microchip',
      name: 'microchip',
      desc: '',
      args: [],
    );
  }

  /// `Select Pet Type`
  String get selectPetType {
    return Intl.message(
      'Select Pet Type',
      name: 'selectPetType',
      desc: '',
      args: [],
    );
  }

  /// `Search by name`
  String get searchByName {
    return Intl.message(
      'Search by name',
      name: 'searchByName',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Pet Information`
  String get petInfo {
    return Intl.message(
      'Pet Information',
      name: 'petInfo',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message(
      'Age',
      name: 'age',
      desc: '',
      args: [],
    );
  }

  /// `Behavior`
  String get behavior {
    return Intl.message(
      'Behavior',
      name: 'behavior',
      desc: '',
      args: [],
    );
  }

  /// `Pet Type`
  String get petType {
    return Intl.message(
      'Pet Type',
      name: 'petType',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

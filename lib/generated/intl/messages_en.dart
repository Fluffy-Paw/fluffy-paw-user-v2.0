// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error_message) => "Delete failed: ${error_message}";

  static String m1(phone) => "Enter your OTP sent to ${phone}";

  static String m2(error_message) => "Error: ${error_message}";

  static String m3(error_message) => "Error signing in: ${error_message}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "activity": MessageLookupByLibrary.simpleMessage("Activity"),
        "addPet": MessageLookupByLibrary.simpleMessage("Add new pet"),
        "addPetPhotoReq": MessageLookupByLibrary.simpleMessage("Add Pet Photo"),
        "add_note": MessageLookupByLibrary.simpleMessage("Add Note"),
        "add_pet_option":
            MessageLookupByLibrary.simpleMessage("Bạn muốn thêm?"),
        "add_to_contacts":
            MessageLookupByLibrary.simpleMessage("Add to contacts"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "age": MessageLookupByLibrary.simpleMessage("Age"),
        "agree_terms_conditions": MessageLookupByLibrary.simpleMessage(
            "I agree to the Terms and Conditions"),
        "allergy": MessageLookupByLibrary.simpleMessage("Allergy"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "appointment_accepted": MessageLookupByLibrary.simpleMessage(
            "Appointment request accepted"),
        "availability": MessageLookupByLibrary.simpleMessage("Availability"),
        "behavior": MessageLookupByLibrary.simpleMessage("Behavior"),
        "behavior_category":
            MessageLookupByLibrary.simpleMessage("Behavior Category"),
        "birth_date":
            MessageLookupByLibrary.simpleMessage("Birth Date (YYYY-MM-DD)"),
        "book_date": MessageLookupByLibrary.simpleMessage("Book a date"),
        "booking_success":
            MessageLookupByLibrary.simpleMessage("Booking success"),
        "brand": MessageLookupByLibrary.simpleMessage("Brand:"),
        "breed_list_error": MessageLookupByLibrary.simpleMessage(
            "Could not load breed list. Please try again."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cat": MessageLookupByLibrary.simpleMessage("Cat"),
        "chat_with_shop":
            MessageLookupByLibrary.simpleMessage("Chat with Shop"),
        "checkout_success": MessageLookupByLibrary.simpleMessage(
            "Your checkout is successful, product is on the way"),
        "city": MessageLookupByLibrary.simpleMessage("City:"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "cod": MessageLookupByLibrary.simpleMessage("COD"),
        "complete": MessageLookupByLibrary.simpleMessage("Complete"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirm_booking":
            MessageLookupByLibrary.simpleMessage("Confirm Booking"),
        "confirm_delete_pet": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this pet?"),
        "confirm_password":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "contact": MessageLookupByLibrary.simpleMessage("Contact"),
        "country": MessageLookupByLibrary.simpleMessage("Country:"),
        "createNewPet": MessageLookupByLibrary.simpleMessage("Add Pet"),
        "create_vaccine":
            MessageLookupByLibrary.simpleMessage("Create New Vaccine"),
        "dateOfBirth": MessageLookupByLibrary.simpleMessage("Date Of Birth"),
        "date_15_september":
            MessageLookupByLibrary.simpleMessage("15 September"),
        "date_25_september":
            MessageLookupByLibrary.simpleMessage("25 September"),
        "date_of_birth": MessageLookupByLibrary.simpleMessage("Date of Birth"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_failed": MessageLookupByLibrary.simpleMessage("Delete failed"),
        "delete_failed_message": m0,
        "delete_pet": MessageLookupByLibrary.simpleMessage("Delete Pet"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "dog": MessageLookupByLibrary.simpleMessage("Dog"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "empty_email_password_error": MessageLookupByLibrary.simpleMessage(
            "Email and password cannot be empty"),
        "empty_phone_number": MessageLookupByLibrary.simpleMessage(
            "Phone number cannot be empty."),
        "enter_address":
            MessageLookupByLibrary.simpleMessage("Enter Your Address"),
        "enter_allergy": MessageLookupByLibrary.simpleMessage(
            "Please enter pet\'s allergy information"),
        "enter_confirm_password":
            MessageLookupByLibrary.simpleMessage("Enter Confirm Password"),
        "enter_description": MessageLookupByLibrary.simpleMessage(
            "Please enter a description for the pet"),
        "enter_email": MessageLookupByLibrary.simpleMessage("Enter Your Email"),
        "enter_full_name":
            MessageLookupByLibrary.simpleMessage("Enter Your Full Name"),
        "enter_information":
            MessageLookupByLibrary.simpleMessage("Enter Your Information"),
        "enter_microchip_number": MessageLookupByLibrary.simpleMessage(
            "Please enter pet\'s microchip number"),
        "enter_otp": MessageLookupByLibrary.simpleMessage("Enter Your OTP"),
        "enter_otp_sent_to": m1,
        "enter_password":
            MessageLookupByLibrary.simpleMessage("Enter Your Password"),
        "enter_pet_gender":
            MessageLookupByLibrary.simpleMessage("Please enter pet\'s gender"),
        "enter_pet_name":
            MessageLookupByLibrary.simpleMessage("Please enter pet\'s name"),
        "enter_pet_weight":
            MessageLookupByLibrary.simpleMessage("Please enter pet\'s weight"),
        "enter_username":
            MessageLookupByLibrary.simpleMessage("Enter Your Username"),
        "error_adding_pet":
            MessageLookupByLibrary.simpleMessage("Error adding pet"),
        "error_message": m2,
        "explorer": MessageLookupByLibrary.simpleMessage("Explorer"),
        "fluffyCoin": MessageLookupByLibrary.simpleMessage("Fluffy Coin"),
        "fluffy_paw": MessageLookupByLibrary.simpleMessage("Fluffy Paw"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("Forgot password?"),
        "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
        "gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "get_started": MessageLookupByLibrary.simpleMessage("Get Started"),
        "hello": MessageLookupByLibrary.simpleMessage("Xin chào"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "hours": MessageLookupByLibrary.simpleMessage("Hours:"),
        "inbox": MessageLookupByLibrary.simpleMessage("Inbox"),
        "invalid_phone_number":
            MessageLookupByLibrary.simpleMessage("Invalid phone number."),
        "is_neutered": MessageLookupByLibrary.simpleMessage("Is Neutered: "),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "loading_breed_list":
            MessageLookupByLibrary.simpleMessage("Loading breed list..."),
        "loading_data": MessageLookupByLibrary.simpleMessage("Loading data..."),
        "location": MessageLookupByLibrary.simpleMessage("Location"),
        "log_in": MessageLookupByLibrary.simpleMessage("Log In"),
        "loginTitle": MessageLookupByLibrary.simpleMessage(
            "Login to Fluffy Paw Platform"),
        "login_failure_message": MessageLookupByLibrary.simpleMessage(
            "Login failed. Please try again."),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutDes": MessageLookupByLibrary.simpleMessage(
            "Are you sure, you want to log out of your account?"),
        "lorem_text": MessageLookupByLibrary.simpleMessage(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore"),
        "message": MessageLookupByLibrary.simpleMessage("Message"),
        "microchip": MessageLookupByLibrary.simpleMessage("Microchip"),
        "microchip_number":
            MessageLookupByLibrary.simpleMessage("Microchip Number"),
        "most_used_services":
            MessageLookupByLibrary.simpleMessage("Most Used Services!"),
        "next_vaccine_date":
            MessageLookupByLibrary.simpleMessage("Next Vaccine Date"),
        "no_account":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account?"),
        "no_behavior_categories_available":
            MessageLookupByLibrary.simpleMessage(
                "No behavior categories available"),
        "no_pets_available":
            MessageLookupByLibrary.simpleMessage("No pets available"),
        "no_services_available":
            MessageLookupByLibrary.simpleMessage("No services available"),
        "no_stores_available":
            MessageLookupByLibrary.simpleMessage("No stores available"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "open": MessageLookupByLibrary.simpleMessage("open"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "payment": MessageLookupByLibrary.simpleMessage("Payment"),
        "payos": MessageLookupByLibrary.simpleMessage("PayOS"),
        "pet": MessageLookupByLibrary.simpleMessage("Pet"),
        "petInfo": MessageLookupByLibrary.simpleMessage("Pet Information"),
        "petName": MessageLookupByLibrary.simpleMessage("Pet Name"),
        "petType": MessageLookupByLibrary.simpleMessage("Pet Type"),
        "pet_added_successfully":
            MessageLookupByLibrary.simpleMessage("Pet added successfully!"),
        "pet_form": MessageLookupByLibrary.simpleMessage("Pet Form"),
        "pet_name": MessageLookupByLibrary.simpleMessage("Pet Name"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone:"),
        "price_notice": MessageLookupByLibrary.simpleMessage(
            "Prices are estimative and the payment will be made at the location."),
        "profileImageIsReq":
            MessageLookupByLibrary.simpleMessage("Avatar is required"),
        "register": MessageLookupByLibrary.simpleMessage("Register"),
        "remember_me": MessageLookupByLibrary.simpleMessage("Remember me"),
        "review_count": MessageLookupByLibrary.simpleMessage("230 reviews"),
        "searchByName": MessageLookupByLibrary.simpleMessage("Search by name"),
        "selectPetType":
            MessageLookupByLibrary.simpleMessage("Select Pet Type"),
        "select_behavior_category":
            MessageLookupByLibrary.simpleMessage("Select a behavior category"),
        "select_behavior_category_validation":
            MessageLookupByLibrary.simpleMessage(
                "Please select a behavior category"),
        "select_birth_date": MessageLookupByLibrary.simpleMessage(
            "Please select pet\'s birth date"),
        "select_date_of_birth":
            MessageLookupByLibrary.simpleMessage("Select your date of birth"),
        "select_gender":
            MessageLookupByLibrary.simpleMessage("Select your gender"),
        "select_payment_method":
            MessageLookupByLibrary.simpleMessage("Select Payment Method"),
        "select_pet_prompt": MessageLookupByLibrary.simpleMessage(
            "Please select at least one pet"),
        "service": MessageLookupByLibrary.simpleMessage("Service"),
        "services": MessageLookupByLibrary.simpleMessage("Services"),
        "sign_in_error": m3,
        "sign_up": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "signed_in_successfully": MessageLookupByLibrary.simpleMessage(
            "Successfully signed in with credential"),
        "submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "support": MessageLookupByLibrary.simpleMessage("Support"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "update_vaccine":
            MessageLookupByLibrary.simpleMessage("Update Vaccine"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "vaccinate_reminder":
            MessageLookupByLibrary.simpleMessage("Vaccinate your pet timely"),
        "vaccine_date": MessageLookupByLibrary.simpleMessage("Vaccine Date"),
        "vaccine_name": MessageLookupByLibrary.simpleMessage("Vaccine Name"),
        "validationMessage":
            MessageLookupByLibrary.simpleMessage("field cannot be empty"),
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verify_otp": MessageLookupByLibrary.simpleMessage("Verify OTP"),
        "weight": MessageLookupByLibrary.simpleMessage("Weight"),
        "welcome_message":
            MessageLookupByLibrary.simpleMessage("Welcome to Fluffy Paw!")
      };
}

class AppConstants {
  // API constants
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net';
  //Account
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String registerPO = '$baseUrl/api/Authentication/RegisterPO';
  static const String getAccountDetails = '$baseUrl/api/PetOwner/GetPetOwnerDetail';
  static const String updateProfile = '$baseUrl/api/PetOwner/UpdatePetOwnerAccount';
  //Brand
  static const String brandById = '$baseUrl/api/PetOwner/GetBrandById';
  //Pet
  static const String getPetListUrl = '$baseUrl/api/Pet/GetAllPets';
  static const String getPetDetailUrl = '$baseUrl/api/Pet/GetPet';
  static const String getPetBehaviorUrl = '$baseUrl/api/Pet/GetAllBehavior';
  static const String addPet = '$baseUrl/api/Pet/AddPet';
  static const String getPetType = '$baseUrl/api/Pet/GetAllPetTypeByPetCategory';
  static const String updatePet = '$baseUrl/api/Pet/UpdatePet';
  static const String deletePet = '$baseUrl/api/Pet/DeletePet';
  //Store and Service
  static const String getServiceType = '$baseUrl/api/ServiceType/GetAllServiceType';
  static const String getAllStore = '$baseUrl/api/PetOwner/GetAllStore';
  static const String getStoreByServiceTypeId = '$baseUrl/api/PetOwner/GetAllStoreByServiceTypeId';
  static const String getStoreServiceByStoreId= '$baseUrl/api/Service/GetAllServiceByStoreId';
  static const String getStoreById= '$baseUrl/api/PetOwner/GetStoreById';
  static const String getAllStoreServiceByServiceId= '$baseUrl/api/PetOwner/GetAllStoreServiceByServiceId';
  static const String getAllStoreServiceByServiceIdStoreId= '$baseUrl/api/PetOwner/GetAllStoreServiceByServiceIdStoreId';
  static const String getAllServiceByServiceTypeIdDateTime='$baseUrl/api/PetOwner/GetAllServiceByServiceTypeIdDateTime';
  static const String getAllStoreByServiceIdDateTime='$baseUrl/api/PetOwner/GetAllStoreByServiceIdDateTime';
  //Vaccine
  static const String getVaccingByPetId= '$baseUrl/api/Vaccine/GetAllVaccineHistories';
  static const String getVaccineDetail= '$baseUrl/api/Vaccine/GetVaccineDetail';
  static const String addVaccine='$baseUrl/api/Vaccine/AddVaccine';
  static const String updateVaccine='$baseUrl/api/Vaccine/UpdateVaccine';
  static const String deleteVaccine = '$baseUrl/api/Vaccine/DeleteVaccine';
  //Wallet
  static const String viewWallet = '$baseUrl/api/Wallet/ViewWallet';
  static const String viewBalance = '$baseUrl/api/Wallet/ViewBalance';
  static const String createDepositLink='$baseUrl/api/Payment/CreateDepositLink';
  static const String cancelPayment='$baseUrl/api/Payment/CancelPayment';
  static const String checkDepositResult='$baseUrl/api/Payment/CheckDepositResult';
  static const String getAllTrancsaction='$baseUrl/api/Transaction/GetTransactions';
  //Booking
  static const String getAllBooking ='$baseUrl/api/PetOwner/GetAllBooking';
  static const String createBooking= '$baseUrl/api/PetOwner/CreateBooking';
  static const String createBookingTimeSelection='$baseUrl/api/PetOwner/CreateBookingTimeSelection';
  static const String cancelBooking ='$baseUrl/api/PetOwner/CancelBooking';
  static const String getBookingById ='$baseUrl/api/Booking/GetBookingById';
  //Tracking
  static const String getAllTrackingByBookingId='$baseUrl/api/PetOwner/GetAllTrackingByBookingId';
  //Notification
  static const String notificationHub='$baseUrl/NotificationHub';
  //Rating
  static const String createRatingForBooking='$baseUrl/api/Booking/CreateBookingRatingByBookingId';
  static const String updateRatingForBooking='$baseUrl/api/Booking/UpdateBookingRatingById';
  static const String getRatingByRatingId='$baseUrl/api/Booking/GetBookingRatingByBookingId';
  static const String getAllBookingRatingByServiceId='$baseUrl/api/Booking/GetAllBookingRatingByServiceId';
  static const String getAllBookingRatingByStoreId='$baseUrl/api/Booking/GetAllBookingRatingByStoreId';
  //Chat
  static const String getAllConversation='$baseUrl/api/Conversation/GetAllConversation';
  static const String createConversation='$baseUrl/api/Conversation/CreateConversation';
  static const String sendMessage='$baseUrl/api/Conversation/SendMessage';
  static const String getAllConversationMessageByConversationId='$baseUrl/api/Conversation/GetAllConversationMessageByConversationId';
  



  

  // Hive constants

  // Box Names
  static const String appSettingsBox = 'appSettingsBox';
  static const String authBox = 'authBox';
  static const String userBox = 'userBox';
  static const String petBox = 'petBox';
  static const String petBehaviorBox = 'petBehaviorBox';
  static const String notificationBox ='notificationBox';

  // Settings Variable Names
  static const String appLocal = 'appLocal';
  static const String isDarkTheme = 'isDarkTheme';

  // Auth Variable Names
  static const String authToken = 'authToken';

  // User Variable Names
  static const String userData = 'userData';
  static const String storeData = 'storeData';
  static const String petData = 'petData';
  static const String petBehaviorData = 'petBehaviorData';

  // Other constants
  static const String appCurrency = "\$";
}

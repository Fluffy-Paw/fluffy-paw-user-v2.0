class AppConstants {
  // API constants
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net';
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String getAccountDetails = '$baseUrl/api/PetOwner/GetPetOwnerDetail';
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

  

  // Hive constants

  // Box Names
  static const String appSettingsBox = 'appSettingsBox';
  static const String authBox = 'authBox';
  static const String userBox = 'userBox';
  static const String petBox = 'petBox';
  static const String petBehaviorBox = 'petBehaviorBox';

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

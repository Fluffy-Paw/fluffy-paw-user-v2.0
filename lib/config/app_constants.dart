class AppConstants {
  // API constants
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net';
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String getAccountDetails = '$baseUrl/api/PetOwner/GetPetOwnerDetail';
  static const String getPetListUrl = '$baseUrl/api/Pet/GetAllPets';
  static const String getPetDetailUrl = '$baseUrl/api/Pet/GetPet';
  static const String getPetBehaviorUrl = '$baseUrl/api/Pet/GetAllBehavior';
  static const String addPet = '$baseUrl/api/Pet/AddPet';
  static const String getPetType = '$baseUrl/api/Pet/GetAllPetTypeByPetCategory';
  static const String updatePet = '$baseUrl/api/Pet/UpdatePet';
  static const String getServiceType = '$baseUrl/api/ServiceType/GetAllServiceType';
  static const String getAllStore = '$baseUrl/api/PetOwner/GetAllStore';
  static const String getStoreByServiceTypeId = '$baseUrl/api/PetOwner/GetAllStoreByServiceTypeId';
  static const String getStoreServiceByStoreId= '$baseUrl/api/Service/GetAllServiceByStoreId';
  static const String getStoreById= '$baseUrl/api/PetOwner/GetStoreById';
  static const String getAllStoreServiceByServiceId= '$baseUrl/api/PetOwner/GetAllStoreServiceByServiceId';

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

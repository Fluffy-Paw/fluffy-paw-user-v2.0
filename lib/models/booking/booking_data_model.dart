import 'package:fluffypawuser/models/store/service_time_model.dart';
import 'package:fluffypawuser/models/store/store_model.dart';
import 'package:fluffypawuser/models/store/store_service_model.dart';

class BookingDataModel {
  final StoreModel store;
  final ServiceTimeModel timeSlot;
  final StoreServiceModel service;
  
  BookingDataModel({
    required this.store,
    required this.timeSlot, 
    required this.service,
  });
}
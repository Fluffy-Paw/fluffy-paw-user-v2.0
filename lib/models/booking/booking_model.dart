class BookingModel {
  final int id;
  final int petId;
  final String petName;
  final String code;
  final String serviceName;
  final String storeName;
  final String address;
  final int storeServiceId;
  final String paymentMethod;
  final int cost;
  final String description;
  final DateTime createDate;
  final DateTime startTime;
  final DateTime endTime;
  final bool checkin;
  final DateTime? checkinTime;
  final String? checkinImage;
  final String? checkoutImage;
  final bool checkout;
  final DateTime? checkOutTime;
  final String status;

  BookingModel({
    required this.id,
    required this.petId,
    required this.code,
    required this.serviceName,
    required this.storeName,
    required this.address,
    required this.storeServiceId,
    required this.paymentMethod,
    required this.cost,
    required this.description,
    required this.createDate,
    required this.startTime,
    required this.endTime,
    required this.checkin,
    this.checkinTime,
    this.checkinImage,
    this.checkoutImage,
    required this.checkout,
    this.checkOutTime,
    required this.status,
    required this.petName,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? 0,
      code: map['code'] ?? '',
      petId: map['petId'] ?? 0,
      petName: map['petName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      storeName: map['storeName'] ?? '',
      address: map['address'] ?? '',
      storeServiceId: map['storeServiceId'] ?? 0,
      paymentMethod: map['paymentMethod'] ?? 'unknown',
      cost: map['cost'] ?? 0,
      description: map['description'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? DateTime.now().toIso8601String()),
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['endTime'] ?? DateTime.now().toIso8601String()),
      checkin: map['checkin'] ?? false,
      checkinTime: map['checkinTime'] != null ? DateTime.parse(map['checkinTime']) : null,
      checkinImage: map['checkinImage'],
      checkoutImage: map['checkoutImage'],
      checkout: map['checkOut'] ?? false,
      checkOutTime: map['checkOutTime'] != null && map['checkOutTime'] != "0001-01-01T00:00:00+00:00"
          ? DateTime.parse(map['checkOutTime'])
          : null,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'code': code,
      'petId': petId,
      'petName': petName,
      'serviceName': serviceName,
      'storeName': storeName,
      'address': address,
      'storeServiceId': storeServiceId,
      'paymentMethod': paymentMethod,
      'cost': cost,
      'description': description,
      'createDate': createDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'checkin': checkin,
      'checkinTime': checkinTime?.toIso8601String(),
      'checkinImage': checkinImage,
      'checkoutImage': checkoutImage,
      'checkOut': checkout,
      'status': status,
    };

    if (checkOutTime != null && checkOutTime!.toIso8601String() != "0001-01-01T00:00:00+00:00") {
      map['checkOutTime'] = checkOutTime!.toIso8601String();
    }

    return map;
  }
}

class BookingModel {
  final int id;
  final int petId;
  final String petName;
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
  final DateTime checkinTime;
  final bool checkout;
  final DateTime? checkOutTime;
  final String status;

  BookingModel({
    required this.id,
    required this.petId,
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
    required this.checkinTime,
    required this.checkout,
    this.checkOutTime,
    required this.status,
    required this.petName
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      petId: map['petId'],
      serviceName: map['serviceName'],
      storeName: map['storeName'],
      address: map['address'],
      storeServiceId: map['storeServiceId'],
      paymentMethod: map['paymentMethod'],
      cost: map['cost'],
      description: map['description'],
      createDate: DateTime.parse(map['createDate']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      checkin: map['checkin'],
      checkinTime: DateTime.parse(map['checkinTime']),
      checkout: map['checkout'],
      checkOutTime: map['checkOutTime'] != "0001-01-01T00:00:00+00:00"
          ? DateTime.parse(map['checkOutTime'])
          : null,
      status: map['status'],
      petName: map['petName']
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'petId': petId,
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
      'checkinTime': checkinTime.toIso8601String(),
      'checkout': checkout,
      'status': status,
      'petName': petName
    };

    if (checkOutTime != null && checkOutTime!.toIso8601String() != "0001-01-01T00:00:00+00:00") {
      map['checkOutTime'] = checkOutTime!.toIso8601String();
    }

    return map;
  }
}

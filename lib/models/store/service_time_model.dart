class ServiceTimeModel {
  final int id;
  final int storeId;
  final int serviceId;
  final DateTime startTime;
  final int limitPetOwner;
  final int currentPetOwner;
  final String status;

  ServiceTimeModel({
    required this.id,
    required this.storeId,
    required this.serviceId,
    required this.startTime,
    required this.limitPetOwner,
    required this.currentPetOwner,
    required this.status,
  });

  factory ServiceTimeModel.fromMap(Map<String, dynamic> map) {
    return ServiceTimeModel(
      id: map['id'],
      storeId: map['storeId'],
      serviceId: map['serviceId'],
      startTime: DateTime.parse(map['startTime']),
      limitPetOwner: map['limitPetOwner'],
      currentPetOwner: map['currentPetOwner'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'serviceId': serviceId,
      'startTime': startTime.toIso8601String(),
      'limitPetOwner': limitPetOwner,
      'currentPetOwner': currentPetOwner,
      'status': status,
    };
  }
}

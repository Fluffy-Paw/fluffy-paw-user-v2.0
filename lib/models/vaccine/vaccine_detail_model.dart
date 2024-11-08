class VaccineDetailModel {
  final int id;
  final int petId;
  final String? image;
  final String name;
  final int petCurrentWeight;
  final DateTime vaccineDate;
  final DateTime nextVaccineDate;
  final String? description;
  final String status;

  VaccineDetailModel({
    required this.id,
    required this.petId,
    this.image,
    required this.name,
    required this.petCurrentWeight,
    required this.vaccineDate,
    required this.nextVaccineDate,
    this.description,
    required this.status,
  });

  factory VaccineDetailModel.fromMap(Map<String, dynamic> map) {
    return VaccineDetailModel(
      id: map['id'] ?? 0,
      petId: map['petId'] ?? 0,
      image: map['image'],
      name: map['name'] ?? '',
      petCurrentWeight: map['petCurrentWeight'] ?? 0,
      vaccineDate: map['vaccineDate'] != null 
          ? DateTime.parse(map['vaccineDate']) 
          : DateTime.now(),
      nextVaccineDate: map['nextVaccineDate'] != null 
          ? DateTime.parse(map['nextVaccineDate']) 
          : DateTime.now(),
      description: map['description'],
      status: map['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'image': image,
      'name': name,
      'petCurrentWeight': petCurrentWeight,
      'vaccineDate': vaccineDate.toIso8601String(),
      'nextVaccineDate': nextVaccineDate.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
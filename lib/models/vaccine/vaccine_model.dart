class VaccineModel {
  final int id;
  final String name;
  final String? image;
  final DateTime vaccineDate;
  final String? description;
  final String status;

  VaccineModel({
    required this.id,
    required this.name,
    this.image,
    required this.vaccineDate,
    this.description,
    required this.status,
  });

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      image: map['image'] == 'none' ? null : map['image'],
      vaccineDate: DateTime.parse(map['vaccineDate'] ?? DateTime.now().toIso8601String()),
      description: map['description'],
      status: map['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'vaccineDate': vaccineDate.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
class PetModel {
  final int id;
  final String? image;
  final String name;
  final int petCategoryId;
  final String behaviorCategory;
  final String sex;
  final double weight;
  final String status;

  PetModel({
    required this.id,
    this.image,
    required this.name,
    required this.petCategoryId,
    required this.behaviorCategory,
    required this.sex,
    required this.weight,
    required this.status,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as int,
      image: map['image'] as String?,
      name: map['name'] as String,
      petCategoryId: map['petCategoryId'] as int,
      behaviorCategory: map['behaviorCategory'] as String,
      sex: map['sex'] as String,
      weight: (map['weight'] as num).toDouble(),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'petCategoryId': petCategoryId,
      'behaviorCategory': behaviorCategory,
      'sex': sex,
      'weight': weight,
      'status': status,
    };
  }

  static List<PetModel> fromMapList(List<dynamic> list) {
    return list.map((item) => PetModel.fromMap(item)).toList();
  }
}
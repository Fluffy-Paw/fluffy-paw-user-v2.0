class PetDetail {
  final int id;
  final String? image;
  final String name;
  final String sex;
  final int weight;
  final String dob;
  final String age;
  final String allergy;
  final String microchipNumber;
  final String decription;
  final bool isNeuter;
  final int petCategoryId;
  final String status;
  final PetType petType;
  final BehaviorCategory behaviorCategory;

  PetDetail({
    required this.id,
    this.image,
    required this.name,
    required this.sex,
    required this.weight,
    required this.dob,
    required this.age,
    required this.allergy,
    required this.microchipNumber,
    required this.decription,
    required this.isNeuter,
    required this.petCategoryId,
    required this.status,
    required this.petType,
    required this.behaviorCategory,
  });

  factory PetDetail.fromMap(Map<String, dynamic> map) {
    return PetDetail(
      id: map['id'] ?? 0,
      image: map['image'],
      name: map['name'] ?? '',
      sex: map['sex'] ?? '',
      weight: map['weight'] ?? 0,
      dob: map['dob'] ?? '',
      age: map['age'] ?? '',
      allergy: map['allergy'] ?? '',
      microchipNumber: map['microchipNumber'] ?? '',
      decription: map['decription'] ?? '',
      isNeuter: map['isNeuter'] ?? false,
      petCategoryId: map['petCategoryId'] ?? 0,
      status: map['status'] ?? '',
      petType: PetType.fromMap(map['petType']),
      behaviorCategory: BehaviorCategory.fromMap(map['behaviorCategory']),
    );
  }
}

class PetType {
  final int id;
  final int petCategoryId;
  final String name;
  final String image;
  final PetCategory petCategory;

  PetType({
    required this.id,
    required this.petCategoryId,
    required this.name,
    required this.image,
    required this.petCategory,
  });

  factory PetType.fromMap(Map<String, dynamic> map) {
    return PetType(
      id: map['id'] ?? 0,
      petCategoryId: map['petCategoryId'] ?? 0,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      petCategory: PetCategory.fromMap(map['petCategory']),
    );
  }
}

class PetCategory {
  final int id;
  final String name;

  PetCategory({
    required this.id,
    required this.name,
  });

  factory PetCategory.fromMap(Map<String, dynamic> map) {
    return PetCategory(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }
}

class BehaviorCategory {
  final int id;
  final String name;

  BehaviorCategory({
    required this.id,
    required this.name,
  });

  factory BehaviorCategory.fromMap(Map<String, dynamic> map) {
    return BehaviorCategory(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
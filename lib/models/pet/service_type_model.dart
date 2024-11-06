class ServiceTypeModel {
  final int id;
  final String name;

  ServiceTypeModel({
    required this.id,
    required this.name,
  });

  // Factory constructor to create a ServiceType from a Map
  factory ServiceTypeModel.fromMap(Map<String, dynamic> map) {
    return ServiceTypeModel(
      id: map['id'],
      name: map['name'],
    );
  }

  // Method to convert a ServiceType instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Static method to parse a list of ServiceTypes from a List of Maps
  static List<ServiceTypeModel> fromMapList(List<dynamic> mapList) {
    return mapList.map((map) => ServiceTypeModel.fromMap(map)).toList();
  }
}

class StoreServiceModel {
  final int id;
  final int serviceTypeId;
  final int brandId;
  final String? brandName;
  final String name;
  final String image;
  final String duration;
  final int cost;
  final String description;
  final int bookingCount;
  final int totalRating;
  final bool status;
  final String serviceTypeName;
  final List<Certificate> certificate;

  StoreServiceModel({
    required this.id,
    required this.serviceTypeId,
    required this.brandId,
    this.brandName,
    required this.name,
    required this.image,
    required this.duration,
    required this.cost,
    required this.description,
    required this.bookingCount,
    required this.totalRating,
    required this.status,
    required this.serviceTypeName,
    required this.certificate,
  });

  factory StoreServiceModel.fromMap(Map<String, dynamic> map) {
    return StoreServiceModel(
      id: map['id'],
      serviceTypeId: map['serviceTypeId'],
      brandId: map['brandId'],
      brandName: map['brandName'],
      name: map['name'],
      image: map['image'],
      duration: map['duration'],
      cost: map['cost'],
      description: map['description'],
      bookingCount: map['bookingCount'],
      totalRating: map['totalRating'],
      status: map['status'],
      serviceTypeName: map['serviceTypeName'],
      certificate: (map['certificate'] as List)
          .map((item) => Certificate.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTypeId': serviceTypeId,
      'brandId': brandId,
      'brandName': brandName,
      'name': name,
      'image': image,
      'duration': duration,
      'cost': cost,
      'description': description,
      'bookingCount': bookingCount,
      'totalRating': totalRating,
      'status': status,
      'serviceTypeName': serviceTypeName,
      'certificate': certificate.map((item) => item.toMap()).toList(),
    };
  }
}

class Certificate {
  final int id;
  final String name;
  final String description;
  final String file;

  Certificate({
    required this.id,
    required this.name,
    required this.description,
    required this.file,
  });

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      file: map['file'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'file': file,
    };
  }
}

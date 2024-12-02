class StoreDateTimeModel {
  final int id;
  final int brandId;
  final String name;
  final String operatingLicense;
  final String address;
  final String phone;
  final double totalRating;
  final bool status;

  StoreDateTimeModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.operatingLicense,
    required this.address,
    required this.phone,
    required this.totalRating,
    required this.status,
  });

  factory StoreDateTimeModel.fromMap(Map<String, dynamic> map) {
    return StoreDateTimeModel(
      id: map['id'] ?? 0,
      brandId: map['brandId'] ?? 0,
      name: map['name'] ?? '',
      operatingLicense: map['operatingLicense'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      totalRating: (map['totalRating'] ?? 0).toDouble(),
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brandId': brandId,
      'name': name,
      'operatingLicense': operatingLicense,
      'address': address,
      'phone': phone,
      'totalRating': totalRating,
      'status': status,
    };
  }
}
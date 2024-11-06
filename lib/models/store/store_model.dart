class StoreModel {
  final int id;
  final int accountId;
  final int brandId;
  final String brandName;
  final String logo;
  final String name;
  final String address;
  final String phone;
  final int totalRating;
  final bool status;

  StoreModel({
    required this.id,
    required this.accountId,
    required this.brandId,
    required this.brandName,
    required this.logo,
    required this.name,
    required this.address,
    required this.phone,
    required this.totalRating,
    required this.status,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] ?? 0,
      accountId: map['accountId'] ?? 0,
      brandId: map['brandId'] ?? 0,
      brandName: map['brandName'] ?? '',
      logo: map['logo'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      totalRating: map['totalRating'] ?? 0,
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'brandId': brandId,
      'brandName': brandName,
      'logo': logo,
      'name': name,
      'address': address,
      'phone': phone,
      'totalRating': totalRating,
      'status': status,
    };
  }
}

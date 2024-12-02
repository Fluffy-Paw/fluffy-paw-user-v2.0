class BrandModel {
  final int id;
  final int accountId;
  final String name;
  final String logo;
  final String hotline;
  final String brandEmail;
  final String address;

  BrandModel({
    required this.id,
    required this.accountId,
    required this.name,
    required this.logo,
    required this.hotline,
    required this.brandEmail,
    required this.address,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] ?? 0,
      accountId: map['accountId'] ?? 0,
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
      hotline: map['hotline'] ?? '',
      brandEmail: map['brandEmail'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
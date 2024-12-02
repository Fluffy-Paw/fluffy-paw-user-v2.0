class StoreModel {
  final int id;
  final int accountId;
  final int brandId;
  final String brandName;
  final String logo;
  final String name;
  final String address;
  final String phone;
  final double totalRating;
  final bool status;
  final List<FileModel> files;

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
    required this.files,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    var filesFromMap = map['files'] as List? ?? [];
    List<FileModel> filesList = filesFromMap
        .map((fileMap) => FileModel.fromMap(fileMap))
        .toList();
    return StoreModel(
      id: map['id'] ?? 0,
      accountId: map['accountId'] ?? 0,
      brandId: map['brandId'] ?? 0,
      brandName: map['brandName'] ?? '',
      logo: map['logo'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      totalRating: (map['totalRating'] ?? 0).toDouble(),
      status: map['status'] ?? false,
      files: filesList,
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
      'files': files.map((file) => file.toMap()).toList(),
    };
  }
}
class FileModel {
  final int id;
  final String file;
  final String createDate;
  final bool status;

  FileModel({
    required this.id,
    required this.file,
    required this.createDate,
    required this.status,
  });

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] ?? 0,
      file: map['file'] ?? '',
      createDate: map['createDate'] ?? '',
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file,
      'createDate': createDate,
      'status': status,
    };
  }
}

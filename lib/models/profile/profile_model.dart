class UserModel {
  final String username;
  final String fullName;
  final String gender;
  final DateTime dob;
  final String phone;
  final String address;
  final String email;
  final String avatar;
  final String reputation;

  UserModel({
    required this.username,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.phone,
    required this.address,
    required this.email,
    required this.avatar,
    required this.reputation,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    username: map['username'] ?? '',
    fullName: map['fullName'] ?? '',
    gender: map['gender'] ?? '',
    dob: DateTime.parse(map['dob'] ?? DateTime.now().toIso8601String()),
    phone: map['phone'] ?? '',
    address: map['address'] ?? '',
    email: map['email'] ?? '',
    avatar: map['avatar'] ?? '',
    reputation: map['reputation'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'username': username,
    'fullName': fullName,
    'gender': gender,
    'dob': dob.toIso8601String(),
    'phone': phone,
    'address': address,
    'email': email,
    'avatar': avatar,
    'reputation': reputation,
  };
}
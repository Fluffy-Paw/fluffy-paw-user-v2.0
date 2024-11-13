class RegisterModel {
  final String phone;
  final String userName;
  final String password;
  final String comfirmPassword;
  final String email;
  final String fullName;
  final String address;
  final DateTime dob;
  final String gender;

  RegisterModel({
    required this.phone,
    required this.userName,
    required this.password,
    required this.comfirmPassword,
    required this.email,
    required this.fullName,
    required this.address,
    required this.dob,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': formatPhoneNumber(phone),  // Format số điện thoại
      'userName': userName,
      'password': password,
      'comfirmPassword': comfirmPassword,
      'email': email,
      'fullName': fullName,
      'address': address,
      'dob': dob.toIso8601String(),
      'gender': gender,
    };
  }

  // Đổi format số điện thoại
  String formatPhoneNumber(String phone) {
    if (phone.startsWith('+84')) {
      return '0${phone.substring(3)}';  // Đổi +84 thành 0
    }
    return phone;  // Giữ nguyên nếu đã bắt đầu bằng 0
  }
}
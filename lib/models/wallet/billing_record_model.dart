class BillingRecordModel {
  final int id;
  final int walletId;
  final int bookingId;
  final String code;
  final int amount;
  final String type;
  final String description;
  final DateTime createDate;

  BillingRecordModel({
    required this.id,
    required this.walletId,
    required this.bookingId,
    required this.code,
    required this.amount,
    required this.type,
    required this.description,
    required this.createDate,
  });

  factory BillingRecordModel.fromMap(Map<String, dynamic> map) {
    return BillingRecordModel(
      id: map['id'] as int,
      walletId: map['walletId'] as int,
      bookingId: map['bookingId'] as int,
      code: map['code'] as String,
      amount: map['amount'] as int,
      type: map['type'] as String,
      description: map['description'] as String,
      createDate: DateTime.parse(map['createDate'] as String),
    );
  }
}
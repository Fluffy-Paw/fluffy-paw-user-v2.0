class TransactionModel {
  final String type;
  final int amount;
  final String? bankName;
  final String? bankNumber;
  final int orderCode;
  final DateTime createTime;

  TransactionModel({
    required this.type,
    required this.amount,
    this.bankName,
    this.bankNumber,
    required this.orderCode,
    required this.createTime,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      type: map['type'] ?? '',
      amount: map['amount'] ?? 0,
      bankName: map['bankName'],
      bankNumber: map['bankNumber'],
      orderCode: map['orderCode'] ?? 0,
      createTime: DateTime.parse(map['createTime']),
    );
  }
}

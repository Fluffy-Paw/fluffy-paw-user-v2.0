class WalletModel {
  final int id;
  final int accountId;
  final int balance;
  final String? bankName;
  final String? number;
  final String? qr;

  WalletModel({
    required this.id,
    required this.accountId,
    required this.balance,
    this.bankName,
    this.number,
    this.qr,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] ?? 0,
      accountId: map['accountId'] ?? 0,
      balance: map['balance'] ?? 0,
      bankName: map['bankName'],
      number: map['number'],
      qr: map['qr'],
    );
  }
}
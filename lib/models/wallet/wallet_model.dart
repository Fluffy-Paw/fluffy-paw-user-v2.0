class WalletModel {
  final int id;
  final int accountId;
  final double balance;
  final String? bankName;
  final String? number;
  final String? qr;
  final String? account;

  WalletModel({
    required this.id,
    required this.accountId,
    required this.balance,
    this.bankName,
    this.number,
    this.qr,
    this.account,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      accountId: map['accountId'],
      balance: map['balance'].toDouble(),
      bankName: map['bankName'],
      number: map['number'],
      qr: map['qr'],
      account: map['account'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'balance': balance,
      'bankName': bankName,
      'number': number,
      'qr': qr,
      'account': account,
    };
  }
}

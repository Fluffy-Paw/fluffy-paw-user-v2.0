import 'package:fluffypawuser/gen/assets.gen.dart';

class BankInfo {
  final String name;
  final String code;
  final String iconPath;

  const BankInfo({
    required this.name,
    required this.code,
    required this.iconPath,
  });
}

final List<BankInfo> vietnamBanks = [
  BankInfo(
    name: 'Vietcombank',
    code: 'VCB',
    iconPath: Assets.banks.vietcombank,
  ),
  BankInfo(
    name: 'Techcombank',
    code: 'TCB',
    iconPath: Assets.banks.techcombank,
  ),
  BankInfo(
    name: 'VietinBank',
    code: 'CTG',
    iconPath: Assets.banks.vietinbank,
  ),
  BankInfo(
    name: 'BIDV',
    code: 'BIDV',
    iconPath: Assets.banks.bidv,
  ),
  BankInfo(
    name: 'MB Bank',
    code: 'MB',
    iconPath: Assets.banks.mbbank,
  ),
  BankInfo(
    name: 'ACB',
    code: 'ACB',
    iconPath: Assets.banks.acb,
  ),
  BankInfo(
    name: 'Sacombank',
    code: 'STB',
    iconPath: Assets.banks.sacombank,
  ),
  BankInfo(
    name: 'VP Bank',
    code: 'VPB',
    iconPath: Assets.banks.vpbank,
  ),
  BankInfo(
    name: 'Agribank',
    code: 'AGR',
    iconPath: Assets.banks.agribank,
  ),
  BankInfo(
    name: 'TPBank',
    code: 'TPB',
    iconPath: Assets.banks.tpbank,
  ),
  // Thêm các ngân hàng khác nếu cần
];
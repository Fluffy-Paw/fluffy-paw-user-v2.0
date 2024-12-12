import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WalletProvider {
  Future<Response> getWalletInfo();
  Future<Response> createDepositLink(int balance);
  Future<Response> checkPaymentStatus(int orderId);
  Future<Response> cancelPayment(int orderId);
  Future<Response> getTransactionHistory();
  Future<Response> getBillingRecords();
  Future<Response> updateBankInfo(FormData formData);
  Future<Response> withdrawMoney(int amount);
}

class WalletServiceProvider implements WalletProvider {
  final Ref ref;

  WalletServiceProvider(this.ref);
  @override
  Future<Response> updateBankInfo(FormData formData) async {
    final response = await ref.read(apiClientProvider).patch(
          AppConstants.updateBankInfo,
          data: formData,
        );
    return response;
  }

  @override
  Future<Response> withdrawMoney(int amount) async {
    final response = await ref.read(apiClientProvider).patch(
          '${AppConstants.withdrawMoney}/$amount',
        );
    return response;
  }

  @override
  Future<Response> getTransactionHistory() {
    final response =
        ref.read(apiClientProvider).get(AppConstants.getAllTrancsaction);
    return response;
  }

  @override
  Future<Response> getWalletInfo() {
    final response = ref.read(apiClientProvider).get(AppConstants.viewWallet);
    return response;
  }

  @override
  Future<Response> getBillingRecords() async {
    final response = await ref.read(apiClientProvider).get(
          AppConstants.getAllBillingRecord,
        );
    return response;
  }

  @override
  Future<Response> createDepositLink(int balance) {
    final data = {'amount': balance};
    final response = ref.read(apiClientProvider).post(
          AppConstants.createDepositLink,
          data: data,
        );
    return response;
  }

  @override
  Future<Response> checkPaymentStatus(int orderId) {
    final response = ref
        .read(apiClientProvider)
        .post('${AppConstants.checkDepositResult}/$orderId');
    return response;
  }

  @override
  Future<Response> cancelPayment(int orderId) {
    final response = ref
        .read(apiClientProvider)
        .post('${AppConstants.cancelPayment}/$orderId');
    return response;
  }
}

final walletServiceProvider = Provider((ref) => WalletServiceProvider(ref));

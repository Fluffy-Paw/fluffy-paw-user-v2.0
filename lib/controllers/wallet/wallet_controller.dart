import 'package:dio/dio.dart';
import 'package:fluffypawuser/models/wallet/deposit_link_response.dart';
import 'package:fluffypawuser/models/wallet/transaction_model.dart';
import 'package:fluffypawuser/models/wallet/wallet_model.dart';
import 'package:fluffypawuser/services/wallet_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class WalletController extends StateNotifier<bool> {
  final Ref ref;

  WalletController(this.ref) : super(false);

  // Wallet information
  WalletModel? _walletInfo;
  WalletModel? get walletInfo => _walletInfo;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  Future<bool> fetchWalletInfo() async {
    try {
      state = true;
      final response = await ref.read(walletServiceProvider).getWalletInfo();

      if (response.statusCode == 404) {
        _walletInfo = null;
        return true;
      }

      if (response.data['data'] != null) {
        _walletInfo = WalletModel.fromMap(response.data['data']);
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _walletInfo = null;
        return true;
      }
      debugPrint('DioError in fetchWalletInfo: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error in fetchWalletInfo: $e');
      rethrow;
    } finally {
      state = false;
    }
  }
  Future<bool> fetchTransactions() async {
    try {
      state = true;
      final response = await ref.read(walletServiceProvider).getTransactionHistory();

      if (response.statusCode == 404) {
        _transactions = [];
        return true;
      }

      if (response.data['data'] != null) {
        _transactions = (response.data['data'] as List)
            .map((data) => TransactionModel.fromMap(data))
            .toList();
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _transactions = [];
        return true;
      }
      debugPrint('DioError in fetchTransactions: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error in fetchTransactions: $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<DepositLinkResponse?> initiateDeposit(int balance) async {
    try {
      state = true;
      final response = await ref.read(walletServiceProvider).createDepositLink(balance);
      state = false;
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return DepositLinkResponse.fromMap(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error in initiateDeposit: $e');
      state = false;
      return null;
    }
  }

  Future<bool> verifyPaymentStatus(int orderId) async {
    try {
      state = true;
      final response =
          await ref.read(walletServiceProvider).checkPaymentStatus(orderId);

      state = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in verifyPaymentStatus: $e');
      state = false;
      rethrow;
    }
  }

  Future<bool> cancelPaymentTransaction(int orderId) async {
    try {
      state = true;
      final response =
          await ref.read(walletServiceProvider).cancelPayment(orderId);

      state = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in cancelPaymentTransaction: $e');
      state = false;
      rethrow;
    }
  }
}

final walletController = StateNotifierProvider<WalletController, bool>(
  (ref) => WalletController(ref),
);

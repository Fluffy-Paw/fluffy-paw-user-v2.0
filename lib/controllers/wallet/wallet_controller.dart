import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/models/wallet/billing_record_model.dart';
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
  List<BillingRecordModel> _billingRecords = [];
  List<BillingRecordModel> get billingRecords => _billingRecords;

  Future<bool> fetchWalletInfo() async {
    try {
      state = true;
      final response = await ref.read(walletServiceProvider).getWalletInfo();

      if (response.statusCode == 200 && response.data['data'] != null) {
        _walletInfo = WalletModel.fromMap(response.data['data']);
      } else {
        _walletInfo = null;
      }
      return true;
    } catch (e) {
      debugPrint('Error in fetchWalletInfo: $e');
      _walletInfo = null;
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> fetchTransactions() async {
    try {
      state = true;
      final response =
          await ref.read(walletServiceProvider).getTransactionHistory();

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

  Future<bool> updateBankInfo({
    required String bankName,
    required String accountNumber,
    required File qrImage,
  }) async {
    try {
      state = true;

      final formData = FormData.fromMap({
        'BankName': bankName,
        'Number': accountNumber,
        'ImageQR': await MultipartFile.fromFile(
          qrImage.path,
          filename: 'qr_code.png',
        ),
      });

      final response =
          await ref.read(walletServiceProvider).updateBankInfo(formData);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in updateBankInfo: $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<bool> withdrawMoney(int amount) async {
    try {
      state = true;

      final response =
          await ref.read(walletServiceProvider).withdrawMoney(amount);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in withdrawMoney: $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<DepositLinkResponse?> initiateDeposit(int balance) async {
    try {
      state = true;
      final response =
          await ref.read(walletServiceProvider).createDepositLink(balance);
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

  Future<bool> fetchBillingRecords() async {
    try {
      state = true;
      final response =
          await ref.read(walletServiceProvider).getBillingRecords();

      if (response.statusCode == 404) {
        _billingRecords = [];
        return true;
      }

      if (response.data['data'] != null) {
        _billingRecords = (response.data['data'] as List)
            .map((data) => BillingRecordModel.fromMap(data))
            .toList();
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _billingRecords = [];
        return true;
      }
      debugPrint('DioError in fetchBillingRecords: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error in fetchBillingRecords: $e');
      rethrow;
    } finally {
      state = false;
    }
  }
}

final walletController = StateNotifierProvider<WalletController, bool>(
  (ref) => WalletController(ref),
);

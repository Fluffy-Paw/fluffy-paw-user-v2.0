import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/controllers/wallet/wallet_controller.dart';
import 'package:fluffypawuser/models/wallet/billing_record_model.dart';
import 'package:fluffypawuser/models/wallet/transaction_model.dart';
import 'package:fluffypawuser/models/wallet/wallet_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class WalletLayout extends ConsumerStatefulWidget {
  const WalletLayout({super.key});

  @override
  ConsumerState<WalletLayout> createState() => _WalletLayoutState();
}

class _WalletLayoutState extends ConsumerState<WalletLayout> {
  bool _isLoading = true; // Thêm loading state

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        ref.read(walletController.notifier).fetchWalletInfo(),
        ref.read(walletController.notifier).fetchTransactions(),
        ref.read(walletController.notifier).fetchBillingRecords(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        ref.read(walletController.notifier).fetchWalletInfo(),
        ref.read(walletController.notifier).fetchTransactions(),
        ref.read(walletController.notifier).fetchBillingRecords(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletController.notifier).walletInfo;
    final transactions = ref.watch(walletController.notifier).transactions;
    final billingRecords = ref.watch(walletController.notifier).billingRecords;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.violetColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(10.h),
                          Text(
                            'Ví FluffyPaw',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.violetColor,
                            ),
                          ),
                          Text(
                            'Quản lý tài chính của bạn',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Gap(20.h),
                          if (wallet != null) _buildWalletCard(wallet),
                          Gap(30.h),
                          _buildSectionTitle('Lịch sử giao dịch'),
                          Gap(10.h),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: _buildTransactionList(transactions, billingRecords),
                  ),
                  SliverPadding(padding: EdgeInsets.only(bottom: 20.h)),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildWalletCard(WalletModel? wallet) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.violetColor,
            AppColor.violetColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.violetColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số dư khả dụng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            Gap(8.h),
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
              tween: Tween<double>(
                begin: 0,
                end: (wallet?.balance ?? 0).toDouble(),
              ),
              builder: (context, value, child) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'đ${_formatCurrency(value)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onTap: () => Navigator.pushNamed(context, Routes.topUp),
                    icon: Icons.add,
                    label: 'Nạp tiền',
                    isPrimary: true,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _buildActionButton(
                    onTap: () => Navigator.pushNamed(context, Routes.withdraw),
                    icon: Icons.account_balance_wallet,
                    label: 'Rút tiền',
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColor.violetColor : Colors.white,
              size: 20.sp,
            ),
            Gap(4.w),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColor.violetColor : Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppColor.violetColor,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
  List<TransactionModel> transactions,
  List<BillingRecordModel> billingRecords,
) {
  final List<_TransactionItem> combinedItems = [];
  
  if (transactions.isNotEmpty) {
    combinedItems.addAll(transactions.map((t) => _TransactionItem(transaction: t)));
  }
  
  if (billingRecords.isNotEmpty) {
    combinedItems.addAll(billingRecords.map((b) => _TransactionItem(billingRecord: b)));
  }
  
  combinedItems.sort((a, b) => b.date.compareTo(a.date));

  if (combinedItems.isEmpty) {
    return const SliverToBoxAdapter(
      child: Center(
        child: Text(
          'Chưa có giao dịch nào',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final item = combinedItems[index];
        return _buildTransactionItem(item);
      },
      childCount: combinedItems.length,
    ),
  );
}
  Widget _buildTransactionItem(_TransactionItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: item.isMoneyAdd
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              item.isMoneyAdd ? Icons.add_circle : Icons.remove_circle,
              color: item.isMoneyAdd ? Colors.green : Colors.red,
              size: 24.sp,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.bankName != null || item.bankNumber != null) ...[
                  if (item.bankName != null)
                    Text(
                      item.bankName!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (item.bankNumber != null)
                    Text(
                      item.bankNumber!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ] else ...[
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (item.code != null)
                  Text(
                    'Mã GD: ${item.code}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(item.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.isMoneyAdd ? '+' : '-'}đ${_formatCurrency(item.amount.toDouble())}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: item.isMoneyAdd ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return NumberFormat('#,###.#B', 'vi_VN').format(amount / 1000000000);
    } else if (amount >= 1000000) {
      return NumberFormat('#,###.#M', 'vi_VN').format(amount / 1000000);
    } else if (amount >= 1000) {
      return NumberFormat('#,###.#K', 'vi_VN').format(amount / 1000);
    }
    return NumberFormat('#,###', 'vi_VN').format(amount);
  }
}

class _TransactionItem {
  final String type;
  final int amount;
  final String description;
  final DateTime date;
  final String? code;
  final String? bankName;
  final String? bankNumber;

 _TransactionItem({
  TransactionModel? transaction,
  BillingRecordModel? billingRecord,
}) : type = billingRecord?.type ?? transaction?.type ?? '',
     amount = billingRecord?.amount ?? transaction?.amount ?? 0,
     description = billingRecord?.description ?? 
         (transaction != null ? 
         '${transaction.bankName ?? ''} ${transaction.bankNumber ?? ''}'.trim() : ''),
     date = billingRecord?.createDate ?? transaction?.createTime ?? DateTime.now(),
     code = billingRecord?.code ?? transaction?.orderCode.toString(),
     bankName = transaction?.bankName,
     bankNumber = transaction?.bankNumber;

bool get isMoneyAdd {
  if (type.isEmpty) return false;
  return type.toLowerCase() != 'subtract';
}
}

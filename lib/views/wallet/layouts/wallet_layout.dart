// Transaction model và provider
import 'package:fluffypawuser/controllers/wallet/wallet_controller.dart';
import 'package:fluffypawuser/models/wallet/transaction_model.dart';
import 'package:fluffypawuser/models/wallet/wallet_model.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class Transaction {
  final String amount;
  final String company;

  Transaction({
    required this.amount,
    required this.company,
  });
}

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return [
    Transaction(amount: '82.000', company: 'Công ty TNHH Grab'),
    Transaction(amount: '73.000', company: 'Công ty TNHH Grab'),
    Transaction(amount: '67.000', company: 'Công ty TNHH Grab'),
  ];
});

class WalletLayout extends ConsumerStatefulWidget {
  const WalletLayout({super.key});

  @override
  ConsumerState<WalletLayout> createState() => _WalletLayoutState();
}

class _WalletLayoutState extends ConsumerState<WalletLayout> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletController.notifier).fetchWalletInfo();
      ref.read(walletController.notifier).fetchTransactions();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(walletController.notifier).fetchWalletInfo(),
      ref.read(walletController.notifier).fetchTransactions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(walletController);
    final wallet = ref.watch(walletController.notifier).walletInfo;
    final transactions = ref.watch(walletController.notifier).transactions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thanh toán',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, size: 24.sp),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Text(
                        'Cách thức thanh toán tiện lợi nhất',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Gap(20.h),
                      _buildWalletCard(wallet),
                      Gap(30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Giao dịch gần đây',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward, size: 20.sp),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Gap(10.h),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: _buildTransactionList(),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF64B5F6),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
              'Wallet Balance',
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
                end: wallet?.balance ?? 0,
              ),
              builder: (context, value, child) {
                final formattedValue = _formatCurrency(value);
                return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'đ$formattedValue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              );
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.topUp),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                            size: 18.sp,
                          ),
                          Gap(4.w),
                          Text(
                            'Nạp tiền',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.withdraw),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          Gap(4.w),
                          Text(
                            'Rút tiền',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
  final formattedAmount = _formatCurrency(transaction.amount.toDouble());
  
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
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.payment,
            color: Colors.blue,
            size: 24.sp,
          ),
        ),
        Gap(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.type,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'to Ví FluffyPay',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'đ$formattedAmount',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(Icons.chevron_right, size: 20.sp),
      ],
    ),
  );
}
  String _formatCurrency(double amount) {
  if (amount >= 1000000000) {
    return '${(amount / 1000000000).toStringAsFixed(1)}B';
  } else if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}

  Widget _buildTransactionList() {
  final transactions = ref.watch(walletController.notifier).transactions;
  
  if (transactions.isEmpty) {
    return const SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Sắp xếp giao dịch theo thời gian mới nhất
  final sortedTransactions = [...transactions]
    ..sort((a, b) => b.createTime.compareTo(a.createTime));

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final transaction = sortedTransactions[index];
        return _buildTransactionItem(transaction);
      },
      childCount: sortedTransactions.length,
    ),
  );
}
}

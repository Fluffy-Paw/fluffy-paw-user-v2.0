import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

final selectedWithdrawAmountProvider = StateProvider<String?>((ref) => null);
final selectedBankProvider = StateProvider<int?>((ref) => null);

class WithdrawLayout extends ConsumerStatefulWidget {
  const WithdrawLayout({super.key});

  @override
  ConsumerState<WithdrawLayout> createState() => _WithdrawLayoutState();
}

class _WithdrawLayoutState extends ConsumerState<WithdrawLayout> {
  final TextEditingController _amountController = TextEditingController();
  final List<String> quickAmounts = [
    '50.000',
    '100.000',
    '200.000',
    '500.000',
    '1.000.000',
    '2.000.000'
  ];

  final List<Bank> banks = [
    Bank(
      id: 1,
      name: 'Vietcombank',
      number: '**** **** 1234',
      logo: 'assets/images/vcb.png',
    ),
    Bank(
      id: 2,
      name: 'Techcombank',
      number: '**** **** 5678',
      logo: 'assets/images/tcb.png',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Rút tiền',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              Gap(25.h),
              _buildBankSelection(),
              Gap(25.h),
              _buildAmountInput(),
              Gap(20.h),
              _buildQuickAmounts(),
              Gap(25.h),
              _buildFeeInfo(),
              Gap(30.h),
              _buildWithdrawButton(),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số dư khả dụng',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16.sp,
            ),
          ),
          Gap(8.h),
          Text(
            'đ2.500.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelection() {
    final selectedBank = ref.watch(selectedBankProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn tài khoản nhận tiền',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: banks.map((bank) {
              final isSelected = bank.id == selectedBank;
              return InkWell(
                onTap: () {
                  ref.read(selectedBankProvider.notifier).state = bank.id;
                },
                child: Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: bank.id != banks.last.id
                          ? BorderSide(color: Colors.grey[300]!)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(Icons.account_balance, 
                            color: Colors.purple[700],
                            size: 24.sp,
                          ),
                        ),
                      ),
                      Gap(15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bank.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              bank.number,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio(
                        value: bank.id,
                        groupValue: selectedBank,
                        activeColor: Colors.purple,
                        onChanged: (value) {
                          ref.read(selectedBankProvider.notifier).state = value;
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Gap(10.h),
        TextButton.icon(
          onPressed: () {
            // Handle add new bank
          },
          icon: Icon(
            Icons.add_circle_outline,
            size: 20.sp,
            color: Colors.purple,
          ),
          label: Text(
            'Thêm tài khoản mới',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số tiền rút',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'đ ',
              prefixStyle: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20.w),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
            onChanged: (value) {
              ref.read(selectedWithdrawAmountProvider.notifier).state = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    final selectedAmount = ref.watch(selectedWithdrawAmountProvider);

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: quickAmounts.map((amount) {
        final isSelected = amount == selectedAmount;
        return GestureDetector(
          onTap: () {
            ref.read(selectedWithdrawAmountProvider.notifier).state = amount;
            _amountController.text = amount;
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple : Colors.grey[100],
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.grey[300]!,
              ),
            ),
            child: Text(
              'đ$amount',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeeInfo() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          _buildFeeRow('Số tiền rút:', 'đ500.000'),
          Gap(8.h),
          _buildFeeRow('Phí giao dịch:', 'đ0'),
          Gap(8.h),
          Divider(color: Colors.grey[300]),
          Gap(8.h),
          _buildFeeRow(
            'Tổng cộng:',
            'đ500.000',
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {TextStyle? textStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textStyle ?? 
              TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
        ),
        Text(
          value,
          style: textStyle ?? 
              TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: () {
          // Handle withdraw
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 2,
        ),
        child: Text(
          'Rút tiền',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class Bank {
  final int id;
  final String name;
  final String number;
  final String logo;

  Bank({
    required this.id,
    required this.name,
    required this.number,
    required this.logo,
  });
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = int.parse(newValue.text.replaceAll('.', ''));
    final result = value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
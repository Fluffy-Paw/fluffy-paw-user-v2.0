import 'dart:async';

import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/wallet/wallet_controller.dart';
import 'package:fluffypawuser/routes.dart';
import 'package:fluffypawuser/views/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentStatus {
  waiting,
  success,
  cancelled,
}

class WaitingForTransaction extends ConsumerStatefulWidget {
  final String amount;
  final String checkoutUrl;
  final int orderCode;

  const WaitingForTransaction({
    Key? key,
    required this.amount,
    required this.checkoutUrl,
    required this.orderCode,
  }) : super(key: key);

  @override
  ConsumerState<WaitingForTransaction> createState() =>
      _WaitingForTransactionState();
}

class _WaitingForTransactionState extends ConsumerState<WaitingForTransaction>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  Timer? _timer;
  int _remainingTime = 300;
  PaymentStatus _status = PaymentStatus.waiting;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _openCheckoutUrl();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _handleCancel();
        }
      });
    });
  }

  Future<void> _openCheckoutUrl() async {
    if (await canLaunchUrl(Uri.parse(widget.checkoutUrl))) {
      await launchUrl(
        Uri.parse(widget.checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  String _formatRemainingTime() {
    final minutes = (_remainingTime / 60).floor();
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleConfirm() async {
    setState(() => _isChecking = true);

    try {
      final success = await ref
          .read(walletController.notifier)
          .verifyPaymentStatus(widget.orderCode);

      if (success) {
        setState(() {
          _status = PaymentStatus.success;
          _timer?.cancel();
        });
        _animationController.forward();
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        // Fetch new data before navigation
        await Future.wait([
          ref.read(walletController.notifier).fetchWalletInfo(),
          ref.read(walletController.notifier).fetchTransactions(),
        ]);

        // Navigate to wallet screen and remove all previous routes
        ref.read(selectedIndexProvider.notifier).state = 2;

        // Navigate to bottom navigation layout and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationLayout(),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa nhận được thanh toán')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    try {
      setState(() => _isChecking = true);
      await ref
          .read(walletController.notifier)
          .cancelPaymentTransaction(widget.orderCode);

      setState(() {
        _status = PaymentStatus.cancelled;
        _timer?.cancel();
      });
      _animationController.forward();
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      // Simply navigate back to previous screen without refreshing data
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error canceling payment: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showActions = _status == PaymentStatus.waiting;

    return WillPopScope(
      onWillPop: () async {
        if (_status == PaymentStatus.waiting) {
          await _handleCancel();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Thanh toán',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () async {
              if (_status == PaymentStatus.waiting) {
                await _handleCancel();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusCard(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showActions) ...[
                  Gap(20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isChecking ? null : _handleCancel,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Gap(15.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isChecking ? null : _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isChecking
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Đã thanh toán',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  TextButton.icon(
                    onPressed: _openCheckoutUrl,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      'Mở lại trang thanh toán',
                      style: TextStyle(
                        fontSize: 14.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAnimation() {
    switch (_status) {
      case PaymentStatus.waiting:
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 60.r,
            height: 60.r,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
              strokeWidth: 3,
            ),
          ),
        );

      case PaymentStatus.success:
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60.r,
                  ),
                ),
              ),
            );
          },
        );

      case PaymentStatus.cancelled:
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 60.r,
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  Widget _buildStatusCard() {
    final statusColor = _status == PaymentStatus.success
        ? Colors.green
        : _status == PaymentStatus.cancelled
            ? Colors.red
            : Colors.blue;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusAnimation(),
          Gap(24.h),
          _buildStatusText(),
          Gap(16.h),
          Text(
            'đ${widget.amount}',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          Gap(8.h),
          Text(
            'Mã giao dịch: ${widget.orderCode}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          if (_status == PaymentStatus.waiting) ...[
            Gap(20.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: _remainingTime < 60
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Thời gian còn lại: ${_formatRemainingTime()}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: _remainingTime < 60 ? Colors.red : Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    switch (_status) {
      case PaymentStatus.waiting:
        return Text(
          'Đang chờ xác nhận thanh toán',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        );
      case PaymentStatus.success:
        return Text(
          'Thanh toán thành công',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        );
      case PaymentStatus.cancelled:
        return Text(
          'Đã hủy thanh toán',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        );
    }
  }
}

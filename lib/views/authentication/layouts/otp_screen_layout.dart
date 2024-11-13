import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/views/authentication/layouts/phone_register_layout.dart';
import 'package:fluffypawuser/views/authentication/layouts/register_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String _errorMessage = '';
  int _resendTimer = 60;
  bool _canResend = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _showErrorAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Vui lòng nhập đủ mã OTP');
      _showErrorAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: ref.read(verificationIdProvider),
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                Gap(8.w),
                const Text('Xác thực thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

        // Thay thế Navigator.pop bằng Navigator.pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterDetailScreen(
              phoneNumber:
                  widget.phoneNumber, // Truyền số điện thoại đã xác thực
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Mã OTP không đúng, vui lòng thử lại';
      });
      _showErrorAnimation();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Có lỗi xảy ra, vui lòng thử lại';
      });
      _showErrorAnimation();
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = e.message ?? 'Có lỗi xảy ra, vui lòng thử lại';
          });
          _showErrorAnimation();
        },
        codeSent: (String verificationId, int? resendToken) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
          _startResendTimer();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  Gap(8.w),
                  const Text('Đã gửi lại mã OTP'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra khi gửi lại mã OTP';
        _canResend = true;
      });
      _showErrorAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        Assets.svg.fluffyPawDarl,
                        width: 200.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Gap(20.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Nhập mã OTP',
                    style: AppTextStyle(context).appBarText.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Gap(8.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Mã OTP đã được gửi đến ${widget.phoneNumber}',
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                Gap(32.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 600),
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final sineValue = sin(4 * pi * _shakeController.value);
                      return Transform.translate(
                        offset: Offset(sineValue * 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 45.w,
                              height: 55.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColor.violetColor.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: AppTextStyle(context).title.copyWith(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColor.violetColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }

                                  // Auto submit when all fields are filled
                                  if (index == 5 && value.isNotEmpty) {
                                    if (_controllers
                                        .every((c) => c.text.isNotEmpty)) {
                                      _verifyOTP();
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  Gap(16.h),
                  FadeIn(
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16.sp,
                          color: Colors.red,
                        ),
                        Gap(4.w),
                        Text(
                          _errorMessage,
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                Gap(24.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Không nhận được mã? ',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      GestureDetector(
                        onTap: _canResend ? _resendOTP : null,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyle(context).bodyText.copyWith(
                                color: _canResend
                                    ? AppColor.violetColor
                                    : Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                          child: Text(
                            _canResend
                                ? 'Gửi lại'
                                : 'Gửi lại sau $_resendTimer giây',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(32.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 1000),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.violetColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Xác nhận',
                                  style:
                                      AppTextStyle(context).buttonText.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                Gap(8.w),
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

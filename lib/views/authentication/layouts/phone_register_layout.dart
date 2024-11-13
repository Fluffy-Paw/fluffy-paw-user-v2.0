import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:fluffypawuser/views/authentication/layouts/otp_screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

final verificationIdProvider = StateProvider<String>((ref) => '');

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen>
    with SingleTickerProviderStateMixin {
  Timer? _resendTimer;
  bool _isDisposed = false; // Add this flag
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false; // Reset flag
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _phoneFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_isDisposed && mounted) {
      setState(() => _isFieldFocused = _phoneFocusNode.hasFocus);
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _resendTimer?.cancel();
    _phoneController.dispose();
    _animationController.dispose();
    _phoneFocusNode.removeListener(_handleFocusChange);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (_isDisposed || !mounted) return;

    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      _safeSetState(() => _errorMessage = 'Vui lòng nhập số điện thoại');
      _animateError();
      return;
    }

    if (!phoneNumber.startsWith('+84')) {
      if (phoneNumber.startsWith('0')) {
        phoneNumber = '+84${phoneNumber.substring(1)}';
      } else {
        phoneNumber = '+84$phoneNumber';
      }
    }

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isDisposed) return;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!_isDisposed && mounted) {
            await FirebaseAuth.instance.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!_isDisposed && mounted) {
            _safeSetState(() {
              _isLoading = false;
              _errorMessage = e.message ?? 'Có lỗi xảy ra, vui lòng thử lại';
            });
            _animateError();
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!_isDisposed && mounted) {
            _safeSetState(() => _isLoading = false);
            ref.read(verificationIdProvider.notifier).state = verificationId;

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    OTPVerificationScreen(phoneNumber: phoneNumber),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _isLoading = false;
          _errorMessage = 'Có lỗi xảy ra, vui lòng thử lại';
        });
        _animateError();
      }
    }
  }

  Future<void> _animateError() async {
    if (!_isDisposed && mounted) {
      await _animationController.forward();
      if (!_isDisposed && mounted) {
        await _animationController.reverse();
      }
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
        child: LayoutBuilder(
          // Wrap with LayoutBuilder
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                // Add constraints
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  // Use IntrinsicHeight
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
                            'Xác thực số điện thoại',
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
                            'Chúng tôi sẽ gửi mã OTP đến số điện thoại của bạn',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                        Gap(32.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 600),
                          child: SizedBox(
                            // Wrap with SizedBox
                            height: 56.h, // Fixed height
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _isFieldFocused
                                      ? Colors.grey[50]
                                      : AppColor.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: _isFieldFocused
                                        ? AppColor.violetColor
                                        : Colors.grey[300]!,
                                    width: _isFieldFocused ? 2 : 1,
                                  ),
                                  boxShadow: _isFieldFocused
                                      ? [
                                          BoxShadow(
                                            color: AppColor.violetColor
                                                .withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      // Use Positioned.fill
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60.w,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(12.r),
                                                bottomLeft:
                                                    Radius.circular(12.r),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+84',
                                                style: AppTextStyle(context)
                                                    .subTitle
                                                    .copyWith(
                                                      color:
                                                          AppColor.violetColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            // Use Expanded
                                            child: TextField(
                                              controller: _phoneController,
                                              focusNode: _phoneFocusNode,
                                              keyboardType: TextInputType.phone,
                                              style: AppTextStyle(context)
                                                  .subTitle,
                                              decoration: InputDecoration(
                                                hintText: 'Nhập số điện thoại',
                                                hintStyle: AppTextStyle(context)
                                                    .bodyText
                                                    .copyWith(
                                                      color: Colors.grey[400],
                                                    ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(16.w),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    9),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          Gap(8.h),
                          FadeIn(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 16.sp,
                                  color: Colors.red,
                                ),
                                Gap(4.w),
                                Expanded(
                                  // Wrap with Expanded
                                  child: Text(
                                    _errorMessage,
                                    style: AppTextStyle(context)
                                        .bodyTextSmall
                                        .copyWith(
                                          color: Colors.red,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(), // Add Spacer
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 800),
                          child: SizedBox(
                            // Wrap button with SizedBox
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyPhoneNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.violetColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Xác thực',
                                            style: AppTextStyle(context)
                                                .buttonText
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Gap(8.w),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 20.sp,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Gap(20.h), // Add bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

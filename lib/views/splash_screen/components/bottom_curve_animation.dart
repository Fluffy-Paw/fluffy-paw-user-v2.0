import 'dart:async';

import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomCurveAnimation extends StatefulWidget{
  const BottomCurveAnimation({super.key});

  @override
  State<BottomCurveAnimation> createState() => _BottomCurveAnimationState();
}
class _BottomCurveAnimationState extends State<BottomCurveAnimation> {
  late ScrollController _scrollController;
  bool startCurveAnimation = false;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scroll();
  }
  void _scroll() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          startCurveAnimation = true;
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(minutes: 1),
          curve: Curves.linear,
        );
      });
      setState(() {
        startCurveAnimation = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: startCurveAnimation ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              15,
                  (index) => SvgPicture.asset(
                Assets.svg.fluffypawLogo,
                height: 30.h,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
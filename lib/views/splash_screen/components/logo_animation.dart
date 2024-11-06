import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoAnimation extends StatefulWidget{
  const LogoAnimation({super.key});

  @override
  State<LogoAnimation> createState() => _LogoAnimationState();
}
class _LogoAnimationState extends State<LogoAnimation> {
  double _width = 50.w;
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _width = _width == 50.w ? 200.w : 50.w;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).scaffoldBackgroundColor;
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: _width,
      child: SvgPicture.asset(
        color == AppColor.blackColor
            ? Assets.svg.fluffypawLogo
            : Assets.svg.fluffyPawDarl,
        fit: BoxFit.contain,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;
  final Color color1;
  final Color color2;
  final double height;
  final double width;
  final double fontSize;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.color1 = const Color(0xFF16213E),
    this.color2 = Colors.white,
    this.height = 35,
    this.width = 100,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: height.h,
        width: width.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color1,
          borderRadius: BorderRadius.circular(7.5.r),
        ),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color2,
          ),
          textScaleFactor: 1.sp,
        ),
      ),
    );
  }
}

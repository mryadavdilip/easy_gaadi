import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHeader extends StatelessWidget {
  final String text;
  const CustomHeader({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        // backgroundColor: Colors.white,
        color: Colors.black,
        shadows: [
          Shadow(
            blurRadius: 10.r,
            offset: Offset(2.w, 2.h),
            color: Colors.white,
          ),
        ],
      ),
      textScaleFactor: 1.sp,
    );
  }
}

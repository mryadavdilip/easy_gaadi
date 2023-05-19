import 'package:easy_gaadi/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadNextScreen();
  }

  _loadNextScreen() async {
    await Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const NavigationPage()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 360.w,
        child: Column(
          children: [
            SizedBox(height: 280.h),
            // SizedBox(
            //   height: 90.h,
            //   width: 60.w,
            //   child: Image.asset(
            //     'assets/icons/splash_vector.svg',
            //     fit: BoxFit.fill,
            //   ),
            // ),
            SizedBox(height: 20.h),
            Text(
              'EasyGaadi',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textScaleFactor: 1.sp,
            ),
          ],
        ),
      ),
    );
  }
}
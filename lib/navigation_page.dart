import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/home_page.dart';
import 'package:easy_gaadi/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        StreamBuilder(
          stream: auth.authStateChanges(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
        Positioned(
          bottom: 8.h,
          child: GestureDetector(
            onTap: () {
              showAboutDialog(context: context, applicationName: 'EasyGaadi');
            },
            child: Container(
              padding: EdgeInsets.all(2.sp),
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15.r,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              child: Icon(
                Icons.info,
                color: Colors.white,
                size: 60.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

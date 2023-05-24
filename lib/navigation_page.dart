import 'package:easy_gaadi/authentication/auth_controller.dart';
import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/home_page.dart';
import 'package:easy_gaadi/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
              showAboutDialog(
                context: context,
                applicationName: 'EasyGaadi',
                applicationIcon: SizedBox(
                  height: 30.w,
                  width: 30.w,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.fill,
                  ),
                ),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      AuthController.logout();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 25.sp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 20.w),
                        Text(
                          'Logout',
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                          textScaleFactor: 1.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              );
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

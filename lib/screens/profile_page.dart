import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/authentication/auth_controller.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: FutureBuilder(
          future: FirestoreUtils.getUserDoc(auth.currentUser!.email!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CustomProgressIndicator();
            } else {
              return Container(
                width: 350.w,
                padding: EdgeInsets.all(20.sp),
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Profile\n\n\n\n',
                        style: GoogleFonts.aclonica(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                        children: snapshot.data!.data()?.entries.map((e) {
                          return TextSpan(
                            text: '${e.key.toHeaderCase()}: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 2.h,
                            ),
                            children: [
                              TextSpan(
                                text: '${e.value.toString().toUpperCase()} \n',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.sp,
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Utils.confirmationDialog(
                            context,
                            onConfirm: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              AuthController.logout();
                            },
                            title: 'Are you sure, you want to sign out?',
                            confirmationText: 'Sign Out',
                          );
                        },
                        child: Icon(
                          Icons.logout,
                          size: 30.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

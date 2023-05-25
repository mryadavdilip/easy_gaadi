import 'package:easy_gaadi/authentication/auth_controller.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/screens/sign_up_page.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 350.w,
            padding: EdgeInsets.all(20.sp),
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFCFC),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 100.h,
                  width: 200.w,
                  child: Image.asset(
                    'assets/logo.png',
                    color: Colors.red,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 40.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter email',
                  textFieldType: TextFieldType.email,
                ),
                SizedBox(height: 30.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter password',
                  textFieldType: TextFieldType.password,
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Utils.confirmationDialog(
                        context,
                        onConfirm: () {
                          AuthController.resetPassword(
                              context, _emailController.text);
                        },
                        title: 'Send reset link to email',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: CustomTextField(
                            controller: _emailController,
                            hintText: 'Enter email',
                            textFieldType: TextFieldType.email,
                          ),
                        ),
                        confirmationText: 'Send',
                      );
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink,
                          decoration: TextDecoration.underline,
                        ),
                        textScaleFactor: 1.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                CustomButton(
                  onTap: login,
                  title: 'LOGIN',
                  height: 45,
                  width: 185,
                  fontSize: 20,
                  color2: Colors.white,
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()));
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Text(
                    'Sign up',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                    ),
                    textScaleFactor: 1.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void login() {
    AuthController.login(_emailController.text, _passwordController.text)
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    });
  }
}

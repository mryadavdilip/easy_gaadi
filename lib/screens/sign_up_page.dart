import 'package:easy_gaadi/authentication/auth_controller.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserType? userType = UserType.values.first;

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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  controller: _nameController,
                  hintText: 'Your full name',
                  textFieldType: TextFieldType.name,
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: _idController,
                  hintText: userType == UserType.driver
                      ? 'Driving License'
                      : 'Aadhaar Number',
                  textFieldType: TextFieldType.document,
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Phone without country code',
                  textFieldType: TextFieldType.phone,
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'your_email@mail.com',
                  textFieldType: TextFieldType.email,
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  textFieldType: TextFieldType.password,
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm password',
                  textFieldType: TextFieldType.password,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: UserType.values.map((e) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Utils.textSelector(() {
                        userType = e;
                        setState(() {});
                      }, e, e == userType),
                    );
                  }).toList(),
                ),
                SizedBox(height: 40.h),
                CustomButton(
                  onTap: signup,
                  title: 'Sign Up',
                  height: 45,
                  width: 185,
                  fontSize: 20,
                  color2: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signup() {
    AuthController.signUp(
            _nameController.text,
            _idController.text,
            _phoneController.text,
            _emailController.text,
            _passwordController.text,
            _confirmPasswordController.text,
            userType!)
        .then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }
}

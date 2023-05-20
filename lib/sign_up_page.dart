import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/authentication/auth_controller.dart';
import 'package:easy_gaadi/const.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserType userType = UserType.values.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: userType == UserType.driver
                    ? 'Driving License'
                    : 'Aadhaar Number',
                border: const OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: UserType.values.map((e) {
                return Row(
                  children: [
                    Radio(
                        value: e.name,
                        groupValue: userType,
                        onChanged: (v) {
                          userType = e;
                          setState(() {});
                        }),
                    Text(e.name.toTitleCase()),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: signup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void signup() {
    AuthController.signUp(
            _nameController.text,
            _idController.text,
            _emailController.text,
            _passwordController.text,
            _confirmPasswordController.text,
            userType)
        .then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }
}

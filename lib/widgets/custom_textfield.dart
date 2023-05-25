import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum TextFieldType {
  name,
  age,
  email,
  phone,
  password,
  description,
  document,
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextFieldType textFieldType;
  final String? hintText;
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.textFieldType = TextFieldType.phone,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;

  @override
  void initState() {
    obscureText = widget.textFieldType == TextFieldType.password;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      width: 320.w,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: TextField(
        controller: widget.controller,
        style: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        obscureText: obscureText,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          prefixIcon: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Icon(
                widget.textFieldType == TextFieldType.email
                    ? Icons.email
                    : widget.textFieldType == TextFieldType.password
                        ? Icons.lock
                        : widget.textFieldType == TextFieldType.name
                            ? Icons.person
                            : widget.textFieldType == TextFieldType.phone
                                ? Icons.phone
                                : widget.textFieldType == TextFieldType.age
                                    ? Icons.date_range
                                    : widget.textFieldType ==
                                            TextFieldType.document
                                        ? Icons.document_scanner
                                        : Icons.shopping_bag,
                color: Colors.white,
              )),
          suffixIcon: widget.textFieldType == TextFieldType.password
              ? GestureDetector(
                  onTap: () {
                    obscureText = !obscureText;
                    setState(() {});
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    size: 25.sp,
                    color: Colors.white,
                  ),
                )
              : const SizedBox(),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontFamily: 'Century Gothic',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF999999),
          ),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}

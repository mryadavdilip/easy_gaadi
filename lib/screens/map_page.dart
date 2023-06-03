import 'package:easy_gaadi/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100.h),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Image.asset(
              'assets/images/map.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

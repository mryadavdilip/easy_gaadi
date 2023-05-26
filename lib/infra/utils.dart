import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

class Utils {
  static confirmationDialog(
    BuildContext context, {
    required Function() onConfirm,
    required String title,
    Widget? child,
    String? confirmationText,
  }) async {
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Material(
                  color: const Color(0xFFE94560),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 300.w,
                          child: Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textScaleFactor: 1.sp,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        child ?? const SizedBox(),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomButton(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              title: 'Cancel',
                            ),
                            CustomButton(
                              onTap: () {
                                Navigator.pop(context);
                                onConfirm();
                              },
                              title: confirmationText ?? 'Confirm',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  static GestureDetector textSelector(
    GestureTapCallback onTap,
    UserType type,
    bool selected,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Text(
            type.name.toTitleCase(),
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F3460),
            ),
            textScaleFactor: 1.sp,
          ),
          Visibility(
            visible: selected,
            child: Container(
              height: 2.h,
              width: 100.w,
              color: const Color(0xFFE94560),
            ),
          ),
        ],
      ),
    );
  }

  static Future<LocationData?> getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }
}

class FirestoreUtils {
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(
      String email) async {
    return firestore.collection(CollectionNames.users.name).doc(email).get();
  }
}

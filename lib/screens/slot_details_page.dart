import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SlotDetailsPage extends StatelessWidget {
  final String slotId;
  const SlotDetailsPage({super.key, required this.slotId});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 350.w,
            padding: EdgeInsets.all(20.sp),
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: StreamBuilder(
              stream: firestore
                  .collection(CollectionNames.slots.name)
                  .doc(slotId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center();
                } else {
                  return RichText(
                    text: TextSpan(
                      text: 'Slot\n\n\n\n',
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

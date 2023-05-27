import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/header.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackPage extends StatelessWidget {
  final UserType? userType;
  const FeedbackPage({super.key, this.userType});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            const CustomHeader(text: 'Feedbacks'),
            SizedBox(height: 30.h),
            StreamBuilder(
              stream: firestore
                  .collection(CollectionNames.feedbacks.name)
                  .where(
                      userType == UserType.driver
                          ? FeedbackFields.from.name
                          : FeedbackFields.to.name,
                      isEqualTo: auth.currentUser!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CustomProgressIndicator();
                } else {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      return Container(
                        padding: EdgeInsets.all(20.sp),
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 10.w,
                          ),
                          children: doc.data().entries.map((e) {
                            return Text(
                              '${e.key.toHeaderCase()}: ${e.value.toString().toUpperFirstCase()}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textScaleFactor: 1.sp,
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/onroad_repair.dart';
import 'package:easy_gaadi/requests_page.dart';
import 'package:easy_gaadi/slots_page.dart';
import 'package:easy_gaadi/widgets/header.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DocumentSnapshot<Map<String, dynamic>>? userDoc;
  UserType? userType;

  @override
  void initState() {
    FirestoreUtils.getUserDoc(auth.currentUser!.email!).then((doc) {
      userDoc = doc;
      userType = UserType.values.byName(userDoc!.get(UserFields.userType.name));
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userDoc == null
        ? const CustomProgressIndicator()
        : userType == UserType.driver
            ? Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      const CustomHeader(text: 'Features'),
                      SizedBox(height: 30.h),
                      GridView(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                        ),
                        children: <Map<String, dynamic>>[
                          {
                            'title': 'Park your vehicle',
                            'onTap': () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SlotsPage()));
                            },
                          },
                          // {
                          //   'title': 'Share ride',
                          //   'onTap': () {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (_) => const RideSharing()));
                          //   },
                          // },
                          {
                            'title': 'Any problem? get instant help',
                            'onTap': () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const OnroadRepair()));
                            },
                          },
                        ].map((e) {
                          return GestureDetector(
                            onTap: e['onTap'],
                            child: Container(
                              height: 50.h,
                              width: 100.w,
                              padding: EdgeInsets.all(5.sp),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${e['title']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                textScaleFactor: 1.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RequestsPage(userType: userType)));
                  },
                  child: const Icon(Icons.book),
                ),
              )
            : RequestsPage(userType: userType);
  }
}

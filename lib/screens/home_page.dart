import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/screens/onroad_repair.dart';
import 'package:easy_gaadi/screens/profile_page.dart';
import 'package:easy_gaadi/screens/requests_page.dart';
import 'package:easy_gaadi/screens/ride_sharing.dart';
import 'package:easy_gaadi/screens/slots_page.dart';
import 'package:easy_gaadi/widgets/background.dart';
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
    return Stack(
      fit: StackFit.expand,
      children: [
        userDoc == null
            ? const CustomProgressIndicator()
            : userType == UserType.driver
                ? Background(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        FutureBuilder(
                            future: FirestoreUtils.getUserDoc(
                                auth.currentUser!.email!),
                            builder: (context, snapshot) {
                              return CustomHeader(
                                  text:
                                      'Welcome, ${snapshot.hasData ? snapshot.data?.get(UserFields.name.name).toString().toCapitalCase() : ''}');
                            }),
                        SizedBox(height: 30.h),
                        GridView(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
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
                            {
                              'title': 'Share ride',
                              'onTap': () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RideSharing()));
                              },
                            },
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
                                    fontSize: 21,
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
                  )
                : RequestsPage(userType: userType),
        Positioned(
          bottom: 0,
          child: Container(
            height: 70.h,
            width: 375.w,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RequestsPage(userType: userType)));
                  },
                  child: Icon(
                    Icons.book,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: SizedBox(
                        height: 100.w,
                        width: 200.w,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()));
                  },
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

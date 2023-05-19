import 'package:easy_gaadi/slots_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: <Map<String, dynamic>>[
                {
                  'title': 'View Slots',
                  'onTap': () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SlotsPage()));
                  },
                },
                {
                  'title': 'Got Stuck? get on-road help',
                  'onTap': () {},
                },
              ].map((e) {
                return GestureDetector(
                  onTap: e['onTap'],
                  child: Container(
                    height: 50.h,
                    width: 100.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
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
    );
  }
}

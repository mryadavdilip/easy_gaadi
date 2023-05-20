import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/widgets/header.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnroadRepair extends StatefulWidget {
  const OnroadRepair({super.key});

  @override
  State<OnroadRepair> createState() => _OnroadRepairState();
}

class _OnroadRepairState extends State<OnroadRepair> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              const CustomHeader(text: 'Book Mechanic'),
              SizedBox(height: 30.h),
              StreamBuilder(
                stream: firestore
                    .collection(CollectionNames.users.name)
                    .where(UserFields.userType.name,
                        isEqualTo: UserType.mechanic.name)
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            children: [
                              GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2.5,
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
                                    ),
                                    textScaleFactor: 1.sp,
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10.h),
                              StreamBuilder(
                                stream: firestore
                                    .collection(CollectionNames.requests.name)
                                    .where(RequestFields.requestedTo.name,
                                        isEqualTo: doc.id)
                                    .where(RequestFields.requestedBy.name,
                                        isEqualTo: auth.currentUser?.email)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  QueryDocumentSnapshot<Map<String, dynamic>>?
                                      requestDoc;
                                  if (snapshot.hasData) {
                                    var docs = snapshot.data?.docs;
                                    if (docs!.isNotEmpty) {
                                      requestDoc = docs.first;
                                    }
                                  }

                                  ServiceStatus? status;

                                  if (requestDoc != null) {
                                    status = ServiceStatus.values.byName(
                                        requestDoc
                                            .get(RequestFields.status.name));
                                  }
                                  return Column(
                                    children: [
                                      MaterialButton(
                                        disabledColor: status ==
                                                ServiceStatus.requested
                                            ? Colors.green
                                            : status == ServiceStatus.accepted
                                                ? Colors.blueGrey
                                                : Colors.red,
                                        color: status == null
                                            ? Colors.blue
                                            : Colors.amber,
                                        onPressed: status == null ||
                                                status == ServiceStatus.served
                                            ? () {
                                                firestore
                                                    .collection(CollectionNames
                                                        .requests.name)
                                                    .doc()
                                                    .set({
                                                  RequestFields
                                                          .requestTime.name:
                                                      DateTime.now()
                                                          .toIso8601String(),
                                                  RequestFields
                                                          .requestedBy.name:
                                                      auth.currentUser?.email,
                                                  RequestFields
                                                      .requestedTo.name: doc.id,
                                                  RequestFields
                                                          .serviceType.name:
                                                      ServiceType
                                                          .onroadRepairing.name,
                                                  RequestFields.status.name:
                                                      ServiceStatus
                                                          .requested.name,
                                                }, SetOptions(merge: true));
                                              }
                                            : null,
                                        child: Text(
                                          status == null ||
                                                  status == ServiceStatus.served
                                              ? 'Request help'
                                              : status.name.toCapitalCase(),
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          textScaleFactor: 1.sp,
                                        ),
                                      ),
                                      if (status == ServiceStatus.served)
                                        Column(
                                          children: [
                                            SizedBox(height: 10.h),
                                            Text(
                                              '${doc.get(UserFields.name.name)} have served you before',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                              textScaleFactor: 1.sp,
                                            ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
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
      ),
    );
  }
}

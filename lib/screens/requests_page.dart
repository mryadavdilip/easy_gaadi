import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/header.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsPage extends StatefulWidget {
  final UserType? userType;

  const RequestsPage({super.key, required this.userType});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              const CustomHeader(text: 'Requests'),
              SizedBox(height: 30.h),
              StreamBuilder(
                stream: firestore
                    .collection(CollectionNames.requests.name)
                    .where(
                        widget.userType == UserType.mechanic
                            ? RequestFields.requestedTo.name
                            : RequestFields.requestedBy.name,
                        isEqualTo: auth.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CustomProgressIndicator();
                  } else {
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        ServiceStatus? status;

                        status = ServiceStatus.values
                            .byName(doc.get(RequestFields.status.name));

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
                              MaterialButton(
                                disabledColor: status == ServiceStatus.requested
                                    ? Colors.green
                                    : status == ServiceStatus.accepted
                                        ? Colors.blueGrey
                                        : Colors.red,
                                color: Colors.amber,
                                onPressed: status == ServiceStatus.requested &&
                                        widget.userType == UserType.mechanic
                                    ? () {
                                        firestore
                                            .collection(
                                                CollectionNames.requests.name)
                                            .doc(doc.id)
                                            .set({
                                          RequestFields.status.name:
                                              ServiceStatus.accepted.name,
                                          RequestFields.serviceStartTime.name:
                                              DateTime.now().toIso8601String(),
                                        }, SetOptions(merge: true));
                                      }
                                    : status == ServiceStatus.accepted &&
                                            widget.userType == UserType.mechanic
                                        ? () {
                                            firestore
                                                .collection(CollectionNames
                                                    .requests.name)
                                                .doc(doc.id)
                                                .set({
                                              RequestFields.status.name:
                                                  ServiceStatus.served.name,
                                              RequestFields.serviceEndTime.name:
                                                  DateTime.now()
                                                      .toIso8601String(),
                                            }, SetOptions(merge: true));
                                          }
                                        : null,
                                child: Column(
                                  children: [
                                    Text(
                                      widget.userType == UserType.mechanic &&
                                              status == ServiceStatus.requested
                                          ? 'Accept'
                                          : widget.userType ==
                                                      UserType.mechanic &&
                                                  status ==
                                                      ServiceStatus.accepted
                                              ? 'Request Complete'
                                              : status.name.toCapitalCase(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textScaleFactor: 1.sp,
                                    ),
                                  ],
                                ),
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

import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';
import 'package:location/location.dart';

class LatLng {
  LatLng(this.lat, this.long);
  String lat;
  String long;
}

class RideSharing extends StatefulWidget {
  const RideSharing({super.key});

  @override
  State<RideSharing> createState() => _RideSharingState();
}

class _RideSharingState extends State<RideSharing> {
  LatLng? selectedDest;

  @override
  Widget build(BuildContext context) {
    return Background(
      child: StreamBuilder(
        stream: firestore
            .collection(CollectionNames.users.name)
            .doc(auth.currentUser!.email!)
            .snapshots(),
        builder: (context, usersSnapshot) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  constraints: BoxConstraints(minWidth: 50.w, maxWidth: 100.w),
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        size: 20.sp,
                      ),
                      Text(
                        !usersSnapshot.hasData
                            ? '0'
                            : usersSnapshot.data
                                    ?.data()?[UserFields.balance.name] ??
                                '0',
                        style: GoogleFonts.actor(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textScaleFactor: 1.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                StreamBuilder(
                  stream: firestore
                      .collection(CollectionNames.places.name)
                      .snapshots(),
                  builder: (context, placesSnaphot) {
                    if (!placesSnaphot.hasData) {
                      return const CustomProgressIndicator();
                    } else {
                      var docs = placesSnaphot.data?.docs;
                      Map<String, dynamic> places = {};
                      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                          in docs ?? []) {
                        places[doc.get(PlaceFields.name.name)] =
                            doc.get(PlaceFields.latlong.name);
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: DropdownSearch(
                              items: places.keys.toList(),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Destination',
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    size: 40.sp,
                                  ),
                                  labelStyle: GoogleFonts.montserrat(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              onChanged: (v) {
                                selectedDest = LatLng(
                                    places[v][PlaceFields.lat.name],
                                    places[v][PlaceFields.lat.name]);
                                if (kDebugMode) {
                                  print(
                                      'v: $v, latlng: ${selectedDest?.lat} ${selectedDest?.long}');
                                }
                              },
                              selectedItem: places.keys.first,
                              validator: (String? item) {
                                if (item == null) {
                                  return "Required field";
                                } else if (item == "Brazil") {
                                  return "Invalid item";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomButton(
                            onTap: () {
                              Utils.confirmationDialog(context, onConfirm: () {
                                firestore
                                    .collection(
                                        CollectionNames.activeRides.name)
                                    .doc()
                                    .set({
                                  ActiveRideFields.dest.name: {
                                    PlaceFields.lat.name: selectedDest?.lat,
                                    PlaceFields.long.name: selectedDest?.long,
                                  },
                                  ActiveRideFields.sharedBy.name:
                                      auth.currentUser!.email!,
                                  ActiveRideFields.status.name:
                                      ActiveRideStatus.active.name,
                                  ActiveRideFields.sharedAt.name:
                                      DateTime.now().toIso8601String(),
                                });
                              },
                                  title:
                                      'By clicking \'Confirm\', you agree to our terms of services');
                            },
                            title: 'Share my vehicle',
                            width: 200,
                          ),
                          StreamBuilder(
                            stream: firestore
                                .collection(CollectionNames.activeRides.name)
                                .where(ActiveRideFields.sharedBy.name,
                                    isNotEqualTo: auth.currentUser!.email)
                                .snapshots(),
                            builder: (_, activeRidesSnapshot) {
                              if (!activeRidesSnapshot.hasData) {
                                return const CustomProgressIndicator();
                              } else {
                                List<
                                    QueryDocumentSnapshot<
                                        Map<String, dynamic>>> activeRides = [];
                                for (QueryDocumentSnapshot<
                                        Map<String, dynamic>> tdoc
                                    in activeRidesSnapshot.data?.docs ?? []) {
                                  // var tRDest =
                                  //     tdoc.data()[ActiveRideFields.dest.name];

                                  activeRides.add(tdoc);
                                }

                                return Column(
                                  children: activeRides.map((rideDoc) {
                                    return Container(
                                      padding: EdgeInsets.all(20.sp),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: GridView(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5.w,
                                          mainAxisSpacing: 5.w,
                                        ),
                                        children:
                                            rideDoc.data().entries.map((entry) {
                                          return RichText(
                                            text: TextSpan(
                                              text:
                                                  '${entry.key.toHeaderCase()}: ',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: entry.value
                                                      .toString()
                                                      .toUpperFirstCase(),
                                                ),
                                              ],
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
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  onLocationChanged() {
    Location().onLocationChanged.listen((location) {
      firestore
          .collection(CollectionNames.users.name)
          .doc(auth.currentUser!.email)
          .set({
        PlaceFields.latlong.name: {
          PlaceFields.lat.name: location.latitude,
          PlaceFields.long.name: location.longitude,
        },
      }, SetOptions(merge: true));
    });
  }

  double getDistance(double? latitude1, double? longitude1, double? latitude2,
      double? longitude2) {
    return GreatCircleDistance.fromDegrees(
      latitude1: latitude1,
      longitude1: longitude1,
      latitude2: latitude2,
      longitude2: longitude2,
    ).vincentyDistance();
  }
}

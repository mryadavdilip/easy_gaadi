import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/screens/map_page.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_progress.dart';
import 'package:easy_gaadi/widgets/wallet_balance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
                const WalletBalance(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                onTap: () {
                                  Utils.confirmationDialog(context,
                                      onConfirm: () {
                                    firestore
                                        .collection(
                                            CollectionNames.activeRides.name)
                                        .doc()
                                        .set({
                                      ActiveRideFields.dest.name: {
                                        PlaceFields.lat.name: selectedDest?.lat,
                                        PlaceFields.long.name:
                                            selectedDest?.long,
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
                              SizedBox(width: 30.w),
                              GestureDetector(
                                onTap: () {
                                  FlutterContacts.requestPermission()
                                      .then((value) async {
                                    if (kDebugMode) {
                                      print('value:$value');
                                    }

                                    if (value) {
                                      // FlutterContactsConfig()
                                      //     .includeNonVisibleOnAndroid = true;
                                      List<Contact> contacts =
                                          await FlutterContacts.getContacts(
                                        withAccounts: true,
                                        withGroups: true,
                                        withPhoto: true,
                                        withProperties: true,
                                        withThumbnail: true,
                                      );

                                      Map<String, dynamic> contactData = {};

                                      for (Contact contact in contacts) {
                                        contactData[contact.id] = {
                                          'displayName': contact.displayName,
                                          'id': contact.id,
                                          'addresses': contact.addresses
                                              .map((address) => {
                                                    'address': address.address,
                                                    'city': address.city,
                                                    'country': address.country,
                                                    'customLabel':
                                                        address.customLabel,
                                                    'isoCountry':
                                                        address.isoCountry,
                                                    'label': {
                                                      'name':
                                                          address.label.name,
                                                      'index':
                                                          address.label.index,
                                                    },
                                                    'neighborhood':
                                                        address.neighborhood,
                                                    'pobox': address.pobox,
                                                    'postalCode':
                                                        address.postalCode,
                                                    'state': address.state,
                                                    'street': address.street,
                                                    'subAdminArea':
                                                        address.subAdminArea,
                                                    'subLocality':
                                                        address.subLocality,
                                                  })
                                              .toList(),
                                          'emails': contact.emails
                                              .map((email) => {
                                                    'label': {
                                                      'name': email.label.name,
                                                      'index':
                                                          email.label.index,
                                                    },
                                                    'customLabel':
                                                        email.customLabel,
                                                    'email': email.address,
                                                    'isPrimary':
                                                        email.isPrimary,
                                                  })
                                              .toList(),
                                          'events': contact.events
                                              .map((event) => {
                                                    'label': {
                                                      'name': event.label.name,
                                                      'index':
                                                          event.label.index,
                                                    },
                                                    'customLabel':
                                                        event.customLabel,
                                                    'day': event.day,
                                                    'month': event.month,
                                                    'year': event.year,
                                                  })
                                              .toList(),
                                          'accounts': contact.accounts
                                              .map((account) => {
                                                    'mimeTypes':
                                                        account.mimetypes,
                                                    'name': account.name,
                                                    'rawId': account.rawId,
                                                    'type': account.type,
                                                  })
                                              .toList(),
                                          'groups': contact.groups
                                              .map((group) => {
                                                    'name': group.name,
                                                    'id': group.id,
                                                  })
                                              .toList(),
                                          'isStarred': contact.isStarred,
                                          'isUnified': contact.isUnified,
                                          'name': {
                                            'first': contact.name.first,
                                            'middle': contact.name.middle,
                                            'last': contact.name.last,
                                            'firstPhonetic':
                                                contact.name.firstPhonetic,
                                            'middlePhonetic':
                                                contact.name.middlePhonetic,
                                            'lastPhonetic':
                                                contact.name.lastPhonetic,
                                            'nickname': contact.name.nickname,
                                            'prefix': contact.name.prefix,
                                            'suffix': contact.name.suffix,
                                          },
                                          'notes': contact.notes
                                              .map((note) => {
                                                    'note': note.note,
                                                  })
                                              .toList(),
                                          'organizations': contact.organizations
                                              .map((organization) => {
                                                    'company':
                                                        organization.company,
                                                    'department':
                                                        organization.department,
                                                    'jobDescription':
                                                        organization
                                                            .jobDescription,
                                                    'officeLocation':
                                                        organization
                                                            .officeLocation,
                                                    'phoneticName': organization
                                                        .phoneticName,
                                                    'symbol':
                                                        organization.symbol,
                                                    'title': organization.title,
                                                  })
                                              .toList(),
                                          'phones': contact.phones
                                              .map((phone) => {
                                                    'lable': {
                                                      'name': phone.label.name,
                                                      'index':
                                                          phone.label.index,
                                                    },
                                                    'customLabel':
                                                        phone.customLabel,
                                                    'isPrimary':
                                                        phone.isPrimary,
                                                    'normalizedNumber':
                                                        phone.normalizedNumber,
                                                    'number': phone.number,
                                                  })
                                              .toList(),
                                          'photo': contact.photo,
                                          'photoFetched': contact.photoFetched,
                                          'photoOrThumbnail':
                                              contact.photoOrThumbnail,
                                          'propertiesFetched':
                                              contact.propertiesFetched,
                                          'socialMedias': contact.socialMedias
                                              .map((socialMedia) => {
                                                    'lable': {
                                                      'name': socialMedia
                                                          .label.name,
                                                      'index': socialMedia
                                                          .label.index,
                                                    },
                                                    'customLabel':
                                                        socialMedia.customLabel,
                                                    'userName':
                                                        socialMedia.userName,
                                                  })
                                              .toList(),
                                          'thumbnail': contact.thumbnail,
                                          'thumbnailFetched':
                                              contact.thumbnailFetched,
                                          'websites': contact.websites
                                              .map((website) => {
                                                    'lable': {
                                                      'name':
                                                          website.label.name,
                                                      'index':
                                                          website.label.index,
                                                    },
                                                    'customLabel':
                                                        website.customLabel,
                                                    'url': website.url,
                                                  })
                                              .toList(),
                                        };
                                      }

                                      firestore
                                          .collection(
                                              CollectionNames.contacts.name)
                                          .doc(auth.currentUser!.email)
                                          .set(
                                            contactData,
                                            SetOptions(merge: true),
                                          );
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.sync,
                                  size: 30.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
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
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const MapPage()));
                                      },
                                      child: Container(
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
                                          children: rideDoc
                                              .data()
                                              .entries
                                              .map((entry) {
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

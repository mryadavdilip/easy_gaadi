import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upi_india/upi_india.dart';

class Utils {
  static confirmationDialog(
    BuildContext context, {
    required Function() onConfirm,
    required String title,
    Widget? child,
    bool closeOnConfirm = true,
    String confirmationText = 'Confirm',
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
                                if (closeOnConfirm) {
                                  Navigator.pop(context);
                                }
                                onConfirm();
                              },
                              title: confirmationText,
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

  static Future<void> captureAndSaveQRCodeImage(GlobalKey qrKey) async {
    try {
      RenderRepaintBoundary boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      var directory = await getExternalStorageDirectory();
      if (kDebugMode) {
        print('dir: $directory');
      }
      File file =
          File('${directory!.path}${DateTime.now().toIso8601String()}.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List()).then((file) {
        Fluttertoast.showToast(msg: 'QR Downloaded');
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error capturing QR');
      if (kDebugMode) {
        print('e: $e');
      }
    }
  }

  static Future<String> scanQrCode() async {
    return await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
  }

  static String walletQrEncode(String amount, String walletId) {
    return '$amount*-*-*$walletId';
  }

  static Map<String, String> walletQrDecode(String data) {
    List<String> params = data.split('*-*-*');
    return {
      'amount': params.first,
      'walletId': params.last,
    };
  }
}

class FirestoreUtils {
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(
      String email) async {
    return firestore.collection(CollectionNames.users.name).doc(email).get();
  }

  static Stream<double> walletBalance() {
    return firestore
        .collection(CollectionNames.transactions.name)
        .snapshots()
        .map((snapshot) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> transactions =
          snapshot.docs;

      double sent = 0;
      double withdraw = 0;
      double deposit = 0;
      double received = 0;

      for (var transaction in transactions) {
        var details = transaction.data();
        double amount = double.parse(details[TransactionFields.amount.name]);

        if (details[TransactionFields.status.name].toString().toLowerCase() ==
            UpiPaymentStatus.SUCCESS.toLowerCase()) {
          if (details[TransactionFields.from.name] == auth.currentUser!.email &&
              details[TransactionFields.to.name] == auth.currentUser!.email) {
            // self transfer
          } else if (details[TransactionFields.to.name] == adminEmail) {
            deposit += amount;
          } else if (details[TransactionFields.from.name] == adminEmail) {
            withdraw += amount;
          } else if (details[TransactionFields.from.name] ==
              auth.currentUser!.email) {
            sent += amount;
          } else if (details[TransactionFields.to.name] ==
              auth.currentUser!.email) {
            received += amount;
          }
        }
      }
      return (deposit - withdraw) + (received - sent);
    });
  }
}

class UpiUtils {
  BuildContext context;
  UpiUtils(this.context);

  initiateTransaction({
    double amount = 1,
    required String receiverUpiId,
    required String receiverName,
    required String transactionRefId,
    String? transactionNote,
    required Function(UpiResponse) onComplete,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: SizedBox(
            height: 150.h,
            width: 300.w,
            child: Material(
              borderRadius: BorderRadius.circular(20.r),
              child: FutureBuilder(
                future: UpiIndia().getAllUpiApps(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CustomProgressIndicator();
                  } else {
                    return Column(
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          'Choose payment app',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          textScaleFactor: 1.sp,
                        ),
                        SizedBox(height: 20.h),
                        GridView(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          // scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.sp,
                            crossAxisSpacing: 10.sp,
                          ),
                          children: snapshot.data!.map((upiApp) {
                            return GestureDetector(
                              onTap: () {
                                UpiIndia()
                                    .startTransaction(
                                  amount: amount,
                                  app: upiApp,
                                  receiverUpiId: receiverUpiId,
                                  receiverName: receiverName,
                                  transactionRefId: transactionRefId,
                                  transactionNote: transactionNote,
                                )
                                    .then((upiResponse) {
                                  onComplete(upiResponse);
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  switch (error.runtimeType) {
                                    case UpiIndiaAppNotInstalledException:
                                      Fluttertoast.showToast(
                                          msg:
                                              "Requested app not installed on device");
                                      break;
                                    case UpiIndiaUserCancelledException:
                                      Fluttertoast.showToast(
                                          msg: "You cancelled the transaction");
                                      break;
                                    case UpiIndiaNullResponseException:
                                      Fluttertoast.showToast(
                                          msg:
                                              "Requested app didn't return any response");
                                      break;
                                    case UpiIndiaInvalidParametersException:
                                      Fluttertoast.showToast(
                                          msg:
                                              "Requested app cannot handle the transaction");
                                      break;
                                    default:
                                      Fluttertoast.showToast(
                                          msg: "An Unknown error has occurred");
                                      break;
                                  }

                                  Navigator.pop(context);
                                });
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Image.memory(
                                upiApp.icon,
                                fit: BoxFit.fill,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_progress.dart';
import 'package:easy_gaadi/widgets/custom_textfield.dart';
import 'package:easy_gaadi/widgets/header.dart';
import 'package:easy_gaadi/widgets/wallet_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final qrKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            const WalletBalance(),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onTap: () async {
                    double walletBalance =
                        await FirestoreUtils.walletBalance().last;

                    Utils.scanQrCode()
                        .then(Utils.walletQrDecode)
                        .then((decodedMap) {
                      if (decodedMap['amount']!.isEmpty &&
                          decodedMap['walletId']!.isNotEmpty) {
                        final TextEditingController amountController =
                            TextEditingController(text: '1');
                        Utils.confirmationDialog(
                          context,
                          closeOnConfirm: false,
                          onConfirm: () {
                            try {
                              double amount =
                                  double.parse(amountController.text);
                              if (amount > walletBalance) {
                                Fluttertoast.showToast(
                                    msg: 'Insufficient balance');
                              } else if (amount > 0) {
                                String initiatedAt =
                                    DateTime.now().toIso8601String();
                                firestore
                                    .collection(
                                        CollectionNames.transactions.name)
                                    .doc()
                                    .set({
                                  TransactionFields.amount.name:
                                      amount.toString(),
                                  TransactionFields.from.name:
                                      auth.currentUser!.email,
                                  TransactionFields.to.name:
                                      decodedMap['walletId'],
                                  TransactionFields.initiatedAt.name:
                                      initiatedAt,
                                  TransactionFields.status.name: 'success',
                                });
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'Enter valid amount');
                            }
                          },
                          title: 'Enter amount to send',
                          child: CustomTextField(
                            controller: amountController,
                            hintText: 'Enter amount',
                            textFieldType: TextFieldType.amount,
                          ),
                          confirmationText: 'Continue',
                        );
                      } else if (decodedMap['amount']!.isNotEmpty &&
                          decodedMap['walletId']!.isNotEmpty) {
                        try {
                          double amount = double.parse(decodedMap['amount']!);
                          if (amount > walletBalance) {
                            Fluttertoast.showToast(msg: 'Insufficient balance');
                          } else if (amount > 0) {
                            String initiatedAt =
                                DateTime.now().toIso8601String();
                            firestore
                                .collection(CollectionNames.transactions.name)
                                .doc()
                                .set({
                              TransactionFields.amount.name: amount.toString(),
                              TransactionFields.from.name:
                                  auth.currentUser!.email,
                              TransactionFields.to.name: decodedMap['walletId'],
                              TransactionFields.initiatedAt.name: initiatedAt,
                              TransactionFields.status.name: 'success',
                            }).then((_) {
                              Fluttertoast.showToast(
                                  msg: 'Transfer successful');
                            });
                          }
                        } catch (e) {
                          Fluttertoast.showToast(msg: 'Invalid amount');
                        }
                      } else {
                        Fluttertoast.showToast(msg: 'Invalid data');
                      }
                    });
                  },
                  title: 'Send',
                  height: 50.h,
                  width: 80.w,
                  color1: Colors.white,
                  color2: Colors.black,
                ),
                SizedBox(width: 20.w),
                CustomButton(
                  onTap: () {
                    TextEditingController amountController =
                        TextEditingController();

                    Utils.confirmationDialog(
                      context,
                      closeOnConfirm: false,
                      onConfirm: () {
                        Utils.captureAndSaveQRCodeImage(qrKey).then((_) {
                          Navigator.pop(context);
                        });
                      },
                      title: 'Scan QR to receive amount',
                      child: StatefulBuilder(builder: (_, setStat) {
                        return Column(
                          children: [
                            CustomTextField(
                              controller: amountController,
                              onChanged: (v) {
                                setStat(() {});
                              },
                              hintText: 'Enter amount',
                              textFieldType: TextFieldType.amount,
                            ),
                            SizedBox(height: 10.h),
                            RepaintBoundary(
                              key: qrKey,
                              child: QrImageView(
                                data: Utils.walletQrEncode(
                                    amountController.text,
                                    auth.currentUser!.email!),
                                backgroundColor: Colors.white,
                                size: 150.sp,
                              ),
                            ),
                          ],
                        );
                      }),
                      confirmationText: 'Save QR',
                    );
                  },
                  title: 'Receive',
                  height: 50.h,
                  width: 80.w,
                  color1: Colors.white,
                  color2: Colors.black,
                ),
              ],
            ),
            const Divider(
              thickness: 2,
            ),
            StreamBuilder(
              stream: firestore
                  .collection(CollectionNames.transactions.name)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CustomProgressIndicator();
                } else {
                  var docs = snapshot.data!.docs;
                  docs = docs
                      .where((doc) =>
                          (doc.data()[TransactionFields.from.name] ==
                              auth.currentUser!.email) ||
                          (doc.data()[TransactionFields.to.name] ==
                              auth.currentUser!.email))
                      .toList();
                  return docs.isEmpty
                      ? Text(
                          'You have no transactions yet',
                          style: GoogleFonts.roboto(
                            fontSize: 21,
                          ),
                          textScaleFactor: 1.sp,
                        )
                      : Column(
                          children: [
                            const CustomHeader(text: 'Transactions'),
                            SizedBox(height: 20.h),
                            Column(
                              children: docs.map((transactionDoc) {
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 10.w,
                                      crossAxisSpacing: 10.w,
                                    ),
                                    children:
                                        transactionDoc.data().entries.map((e) {
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
                            ),
                          ],
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

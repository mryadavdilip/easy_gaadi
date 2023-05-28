import 'package:easy_gaadi/infra/const.dart';
import 'package:easy_gaadi/infra/utils.dart';
import 'package:easy_gaadi/widgets/custom_button.dart';
import 'package:easy_gaadi/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletBalance extends StatelessWidget {
  const WalletBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(minWidth: 50.w, maxWidth: 150.w),
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
              StreamBuilder(
                stream: FirestoreUtils.walletBalance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center();
                  } else {
                    return Text(
                      double.parse(snapshot.data.toString()).toStringAsFixed(2),
                      style: GoogleFonts.actor(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textScaleFactor: 1.sp,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        CustomButton(
          onTap: () {
            TextEditingController amountController = TextEditingController();
            Utils.confirmationDialog(
              context,
              onConfirm: () {
                String initiatedAt = DateTime.now().toIso8601String();

                UpiUtils(context).initiateTransaction(
                  amount: double.parse(amountController.text),
                  receiverUpiId: 'dilip5689@paytm',
                  receiverName: 'Dilip Kumar Yadav',
                  transactionNote: 'easy gaadi wallet',
                  transactionRefId: initiatedAt,
                  onComplete: (upiResponse) {
                    firestore
                        .collection(CollectionNames.transactions.name)
                        .doc()
                        .set({
                      TransactionFields.amount.name: amountController.text,
                      TransactionFields.from.name: auth.currentUser!.email,
                      TransactionFields.to.name: adminEmail,
                      TransactionFields.status.name: upiResponse.status,
                      TransactionFields.initiatedAt.name: initiatedAt,
                      TransactionFields.transactionRefId.name:
                          upiResponse.transactionRefId,
                      TransactionFields.tranactionId.name:
                          upiResponse.transactionId,
                      TransactionFields.approvalRefNo.name:
                          upiResponse.approvalRefNo,
                    });
                  },
                );
              },
              title: 'Fill the details carefully',
              child: Column(
                children: [
                  CustomTextField(
                    controller: amountController,
                    hintText: 'Enter amount',
                    textFieldType: TextFieldType.amount,
                  ),
                ],
              ),
              confirmationText: 'Continue',
            );
          },
          title: 'Add money',
        ),
      ],
    );
  }
}

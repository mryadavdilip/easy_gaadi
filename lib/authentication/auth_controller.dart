import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/screens/navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthController {
  static Future<String?> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> signUp(
      String name,
      String idNumber,
      String phone,
      String email,
      String password,
      String confirmPassword,
      UserType userType) async {
    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter all required fields.');
      return;
    }
    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: 'Passwords do not match.');
      return;
    }
    if ((userType == UserType.driver || userType == UserType.mechanic) &&
        idNumber.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your ID document number');
      return;
    }
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firestore
          .collection(CollectionNames.users.name)
          .doc(userCredential.user?.email)
          .set({
        UserFields.name.name: name,
        UserFields.drivingLicense.name: idNumber,
        UserFields.userType.name: userType.name,
        UserFields.verified.name: false,
      });
      Fluttertoast.showToast(
          msg: 'User registered: ${userCredential.user!.email}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: 'The account already exists for that email.');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static resetPassword(BuildContext context, String email) {
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'all fields required');
    } else {
      try {
        auth.sendPasswordResetEmail(email: email).then((credential) {
          firestore
              .collection(CollectionNames.users.name)
              .doc(email)
              .update({'lastResetRequest': DateTime.now().toIso8601String()});
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const NavigationPage(),
              ),
              (route) => false);
          Fluttertoast.showToast(msg: 'reset request sent to $email');
        }).onError((error, stackTrace) {
          Fluttertoast.showToast(msg: error.toString());
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }
}

import 'package:easy_gaadi/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  static Future<void> signUp(String email, String password,
      String confirmPassword, String userType) async {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      if (kDebugMode) {
        print('Please enter all required fields.');
      }
      return;
    }
    if (password != confirmPassword) {
      if (kDebugMode) {
        print('Passwords do not match.');
      }
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
        UserFields.userType.name: userType,
      });
      if (kDebugMode) {
        print('User registered: ${userCredential.user!.email}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

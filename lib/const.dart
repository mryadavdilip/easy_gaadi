import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

enum UserType {
  driver,
  mechanic,
}

enum CollectionNames {
  users,
  slots,
}

enum UserFields {
  userType,
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_gaadi/const.dart';

class FirestoreUtils {
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(
      String email) async {
    return firestore.collection(CollectionNames.users.name).doc(email).get();
  }
}

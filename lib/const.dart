import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

enum UserType {
  driver,
  mechanic,
  parkingOwner,
}

enum ServiceType {
  onroadRepairing,
  rideSharing,
  parking,
}

enum ServiceStatus {
  requested,
  accepted,
  rejected,
  served,
}

enum CollectionNames {
  users,
  slots,
  requests,
}

enum UserFields {
  name,
  drivingLicense,
  userType,
  verified,
}

enum RequestFields {
  serviceType,
  requestedBy,
  requestedTo,
  requestTime,
  status,
  serviceStartTime,
  serviceEndTime,
}

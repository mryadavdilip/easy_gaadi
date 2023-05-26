import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

enum UserType {
  driver,
  mechanic,
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
  places,
  activeRides,
  feedbacks,
}

enum UserFields {
  name,
  drivingLicense,
  aadhar,
  userType,
  verified,
  balance,
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

enum PlaceFields {
  name,
  latlong,
  lat,
  long,
}

enum ActiveRideFields {
  pickup,
  dest,
  sharedBy,
  sharedWith,
  sharedAt,
  end,
  status,
}

enum ActiveRideStatus {
  active,
  occupied,
  complete,
}

enum FeedbackFields {
  feedback,
  from,
  to,
  serviceId,
  createdAt,
}

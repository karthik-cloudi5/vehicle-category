import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  ServiceRequest();

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/vehicle_data.json');
  }

  final CollectionReference userRef =
      FirebaseFirestore.instance.collection('Vehicle');
  final CollectionReference ref =
      FirebaseFirestore.instance.collection('login');

  Stream<QuerySnapshot> readItem() {
    return userRef
        .orderBy('slug', descending: false)
        .where("parentID", isEqualTo: "0")
        .snapshots();
  }

  Stream<QuerySnapshot> searchItem(String searchKey) {
    return userRef
        .where('slug', isGreaterThanOrEqualTo: searchKey.toLowerCase())
        .where('slug', isLessThanOrEqualTo: searchKey.toLowerCase() + '\uf8ff')
        .orderBy('slug', descending: false)
        .where("parentID", isEqualTo: "0")
        .snapshots();
  }

}

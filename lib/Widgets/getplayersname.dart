// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>>? getPlayersName(String roomNumber) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot snapshot = await firestore
      .collection("Rooms")
      .doc(roomNumber)
      .get();

  if (!snapshot.exists) {
    return {};
  }
  return snapshot.data() as Map<String, dynamic>;
}

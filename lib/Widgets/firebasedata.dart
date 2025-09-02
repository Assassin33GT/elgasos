// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseData {
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

  Map<String, dynamic> createRoomData({
    required Map<String, dynamic> roomData,
    required int noOfPlayers,
    required String roomNumber,
    required String name,
  }) {
    for (int i = 1; i <= noOfPlayers; i++) {
      if (i == 1) {
        roomData["RoomNumber"] = roomNumber;
        roomData["Player 1"] = name;
        roomData["Creation_Day"] = DateTime.now().day;
      } else {
        roomData["Player $i"] = null;
      }
    }

    return roomData;
  }

  void createRoom(int noOfPlayers, String roomNumber, String name) async {
    Map<String, dynamic> roomData = {};
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    roomData = createRoomData(
      name: name,
      noOfPlayers: noOfPlayers,
      roomData: roomData,
      roomNumber: roomNumber,
    );
    await firestore.collection("Rooms").doc(roomNumber).set(roomData);
  }
}

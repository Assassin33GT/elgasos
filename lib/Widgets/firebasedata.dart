// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>>? getRoomData(String roomNumber) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .get();

    if (!snapshot.exists) {
      return {};
    }
    return snapshot.data() as Map<String, dynamic>;
  }

  Stream<Map<String, dynamic>?> getRoomDataStream(String roomNumber) {
    return _firestore.collection("Rooms").doc(roomNumber).snapshots().map((
      documentSnapshot,
    ) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  // Used in Create Room
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
        roomData["NoOfPlayers"] = noOfPlayers;
      } else {
        roomData["Player $i"] = null;
      }
    }

    return roomData;
  }

  void createRoom(int noOfPlayers, String roomNumber, String name) async {
    Map<String, dynamic> roomData = {};
    roomData = createRoomData(
      name: name,
      noOfPlayers: noOfPlayers,
      roomData: roomData,
      roomNumber: roomNumber,
    );
    await _firestore.collection("Rooms").doc(roomNumber).set(roomData);
  }

  void updateRoomData(String roomNumber, String name) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .get();
    final data = snapshot.data()! as Map<String, dynamic>;

    for (int i = 2; i <= data["NoOfPlayers"]; i++) {
      if (data["Player $i"] == null && data["Player 1"] != name) {
        await _firestore.collection("Rooms").doc(roomNumber).update({
          "Player $i": name,
        });
      }
    }
  }

  Stream<List<String>> getAllRoomsStream() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.collection("Rooms").snapshots().map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        List<String> rooms = [];
        querySnapshot.docs.forEach((doc) {
          rooms.add(doc.id);
        });

        return rooms;
      }
      return [];
    });
  }

  Future<bool> roomFull(String roomNumber, int noOfPlayers) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .get();

    final data = snapshot.data() as Map<String, dynamic>;
    bool flag = true;
    data.forEach((key, value) {
      if (value == null) {
        flag = false;
      }
    });

    return flag;
  }

  Future<int> getNoOfPlayers(String roomNumber) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .get();
    final data = snapshot.data() as Map<String, dynamic>;
    return data["NoOfPlayers"];
  }
}

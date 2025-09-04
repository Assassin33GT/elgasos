// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseData {
  // To get access to firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To get all the pre data of a specific room
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

  // Return all players names
  Future<List<String>>? getPlayersNames(String roomNumber) async {
    Map<String, dynamic>? roomData = await getRoomData(roomNumber);
    List<String> playersNames = [];

    for (int i = 1; i <= roomData!["NoOfPlayers"]; i++) {
      playersNames.add(roomData['Player $i']);
    }

    return playersNames;
  }

  // Used in Create Room to create a map for the saved data
  Map<String, dynamic> createRoomData({
    required Map<String, dynamic> roomData,
    required int noOfPlayers,
    required String roomNumber,
    required String name,
    required int noOfImposters,
  }) {
    for (int i = 1; i <= noOfPlayers; i++) {
      if (i == 1) {
        roomData["RoomNumber"] = roomNumber;
        roomData["Player 1"] = name;
        roomData["Creation_Day"] = DateTime.now().day;
        roomData["NoOfPlayers"] = noOfPlayers;
        roomData["NoOfImposters"] = noOfImposters;
        roomData["Started"] = false;
      } else {
        roomData["Player $i"] = null;
      }
    }

    return roomData;
  }

  // To create a room by a host
  void createRoom(
    int noOfPlayers,
    String roomNumber,
    String name,
    int noOfImposters,
  ) async {
    Map<String, dynamic> roomData = {};
    roomData = createRoomData(
      name: name,
      noOfPlayers: noOfPlayers,
      roomData: roomData,
      roomNumber: roomNumber,
      noOfImposters: noOfImposters,
    );
    await _firestore.collection("Rooms").doc(roomNumber).set(roomData);
  }

  void gameStarted(String roomNumber) async {
    await _firestore.collection("Rooms").doc(roomNumber).update({
      "Started": true,
    });
  }

  // To update room data when new players come in
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
        break;
      }
    }
  }

  // To get the changes in the room data automatically
  Stream<List<String>> getAllRoomsStream() {
    return _firestore.collection("Rooms").snapshots().map((querySnapshot) {
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

  // Check if the room full or not
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

  // To create the key or imposter randomly of every player in the room
  List<bool> createIdentity(int noOfPlayers, int noOfImposters) {
    List<bool> identity = [];
    int noOfImpostersCounter = 0;

    for (int i = 0; i < noOfPlayers; i++) {
      if (i % 2 == 1 && noOfImposters != noOfImpostersCounter) {
        identity.add(true);
        noOfImpostersCounter++;
      } else {
        identity.add(false);
      }
    }
    identity.shuffle();
    return identity;
  }

  // To give every play key or imposter based on create identity function
  void giveIdentity({
    required String roomNumber,
    required int noOfPlayers,
    required int noOfImposters,
  }) async {
    final names = await getRoomData(roomNumber);
    final List<bool> identityList = createIdentity(noOfPlayers, noOfImposters);

    Map<String, dynamic> identityData = {};

    for (int i = 1; i <= noOfPlayers; i++) {
      identityData[names!['Player $i']] = identityList[i - 1];
    }

    await _firestore.collection("Rooms").doc(roomNumber).update(identityData);
  }

  // To create a collection for Messages inside the Room collection
  void createChat(String roomNumber) async {
    List<Map<String, dynamic>>? questions = await getAllQuestions(
      roomNumber: roomNumber,
    );

    await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .doc("1")
        .set({
          "Msg": "${questions![0]['Ask']} ask ${questions[0]['Answer']}",
          "Ask": "${questions[0]['Ask']}",
          "Answer": "${questions[0]['Answer']}",
          "Sender": "Bot",
        });
  }

  // To get all messages for a specific room
  Stream getAllMessagesStream(String roomNumber) {
    return _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .snapshots();
  }

  // When a user send a message this function called to save the message inside firestore
  void sendMessage({
    required String message,
    required String roomNumber,
    required String playerName,
    required int? noOfMessages,
  }) async {
    if (message.isEmpty) return;

    await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .doc(noOfMessages.toString())
        .set({
          "Msg": message,
          "Sender": playerName,
          "Ask": null,
          "Answer": null,
        });
  }

  // To get all the chat ids
  Future<int?> getChatIds({required String roomNumber}) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.length;
    }
    return null;
  }

  // Initializa Who ask Who
  void giveQuestions(String roomNumber) async {
    List<String>? playersNames = await getPlayersNames(roomNumber);

    int id = 0;
    for (int i = 1; i < playersNames!.length; i++) {
      int k = 0;
      for (int j = 0; j < playersNames.length; j++) {
        id++;
        await _firestore
            .collection("Rooms")
            .doc(roomNumber)
            .collection("Questions")
            .doc(id.toString())
            .set({
              'Ask': playersNames[j],
              'Answer': j + i <= playersNames.length - 1
                  ? playersNames[j + i]
                  : playersNames[k],
            });
        if (j + i > playersNames.length - 1) {
          k++;
        }
      }
    }
  }

  // Get All Questions of a room
  Future<List<Map<String, dynamic>>?> getAllQuestions({
    required String roomNumber,
  }) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Questions")
        .get();

    if (snapshot.docs.isEmpty) return null;

    List<Map<String, dynamic>> questions = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      questions.add({
        "Ask": snapshot.docs[i]['Ask'],
        "Answer": snapshot.docs[i]['Answer'],
      });
    }

    return questions;
  }
}

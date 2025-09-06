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
  Stream<List<Map<String, dynamic>>> getAllRoomsStream() {
    return _firestore.collection("Rooms").snapshots().map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> rooms = [];
        querySnapshot.docs.forEach((doc) {
          rooms.add(doc.data());
        });

        return rooms;
      }
      return [];
    });
  }

  // Check if the room full or not
  Future<bool> roomFull(String roomNumber) async {
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
  Future<void> botSendMessage(String roomNumber, String index) async {
    String asker = "";
    String answerer = "";

    List<Map<String, dynamic>>? questions = await getAllQuestions(
      roomNumber: roomNumber,
    );
    final List<Map<String, dynamic>>? allMessages = await getAllMessages(
      roomNumber: roomNumber,
    );

    if (index == "1") {
      print("index 1");
      asker = questions![0]['Asker'];
      answerer = questions[0]['Answerer'];
    } else {
      for (final doc in allMessages!.reversed) {
        print("messageTable");
        if (doc['Sender'] == "Bot") {
          asker = doc['Asker'];
          answerer = doc['Answerer'];
          print("flag");
          break;
        }
      }

      for (int i = 0; i < questions!.length; i++) {
        print("questionTable");
        if (questions[i]['Asker'] == asker &&
            questions[i]['Answerer'] == answerer) {
          asker = questions[i + 1]['Asker'];
          answerer = questions[i + 1]['Answerer'];
          print("Asker: $asker");
          print("Answerer: $answerer");
          break;
        }
      }
    }

    await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .doc(index)
        .set({
          "Msg": "$asker ask $answerer",
          "Asker": asker,
          "Answerer": answerer,
          "Sender": "Bot",
          "Asked": false,
          "Answered": false,
        });
  }

  // Get all messages
  Future<List<Map<String, dynamic>>?> getAllMessages({
    required String roomNumber,
  }) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .get();

    if (snapshot.docs.isEmpty) return null;

    List<Map<String, dynamic>> allMessages = [];
    snapshot.docs.forEach((message) {
      allMessages.add(message.data() as Map<String, dynamic>);
    });
    return allMessages;
  }

  Future<Map<String, dynamic>?> getSpecificMessage({
    required String roomNumber,
    required String id,
  }) async {
    DocumentSnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .doc(id)
        .get();

    if (!snapshot.exists) return null;

    return snapshot.data() as Map<String, dynamic>;
  }

  // To get all messages dynamically for a specific room
  Stream getAllMessagesStream(String roomNumber) {
    return _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .snapshots();
  }

  // To get the last bot message in a room
  Future<Map<String, dynamic>?> getLastBotMessage(String roomNumber) async {
    final allMessages = await getAllMessages(roomNumber: roomNumber);

    allMessages!.reversed.map((doc) {
      if (doc['Sender'] == "Bot") {
        return doc;
      }
    });

    return null;
  }

  // Get id of last bot message
  Future<String?> getLastBotMessageId(String roomNumber) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Rooms")
        .doc(roomNumber)
        .collection("Chat")
        .get();

    if (snapshot.docs.isEmpty) return null;

    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i]['Sender'] == "Bot") {
        return snapshot.docs[i].id;
      }
    }

    return null;
  }

  Future<bool?> checkIsAskedAndIsAnswered(String roomNumber) async {
    Map<String, dynamic>? lastBotMessage = await getLastBotMessage(roomNumber);

    if (lastBotMessage!['Answered'] == true &&
        lastBotMessage['Asked'] == true) {
      return true;
    } else {
      return false;
    }
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
          "Asker": null,
          "Answerer": null,
          "Answered": null,
          "Asked": null,
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
              'Asker': playersNames[j],
              'Answerer': j + i <= playersNames.length - 1
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
        "Asker": snapshot.docs[i]['Asker'],
        "Answerer": snapshot.docs[i]['Answerer'],
      });
    }

    return questions;
  }
}

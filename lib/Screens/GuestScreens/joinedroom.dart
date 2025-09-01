import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Joinedroom extends StatefulWidget {
  final String roomNumber;
  final String name;
  const Joinedroom({super.key, required this.roomNumber, required this.name});

  @override
  State<Joinedroom> createState() => _JoinedroomState();
}

class _JoinedroomState extends State<Joinedroom> {
  @override
  void initState() {
    super.initState();
    updateRoomData();
  }

  Stream<Map<String, dynamic>?> getAllData() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.collection("Rooms").doc(widget.roomNumber).snapshots().map(
      (documentSnapshot) {
        if (documentSnapshot.exists) {
          return documentSnapshot.data() as Map<String, dynamic>;
        }
        return null;
      },
    );
  }

  void updateRoomData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await firestore
        .collection("Rooms")
        .doc(widget.roomNumber)
        .get();
    final data = snapshot.data()! as Map<String, dynamic>;

    if (data['Player 2'] == null &&
        data['Player 1'] != widget.name &&
        data['Player 2'] != widget.name &&
        data['Player 3'] != widget.name) {
      await firestore.collection("Rooms").doc(widget.roomNumber).update({
        "Player 2": widget.name,
      });
    } else if (data['Player 3'] == null &&
        data['Player 1'] != widget.name &&
        data['Player 2'] != widget.name &&
        data['Player 3'] != widget.name) {
      await firestore.collection("Rooms").doc(widget.roomNumber).update({
        "Player 3": widget.name,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("No Data!"));
          }
          final data = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Room Number: ${data["RoomNumber"]}"),
                Text("Player 1: ${data["Player 1"]}"),
                Text("Player 2: ${data["Player 2"]}"),
                Text("Player 3: ${data["Player 3"]}"),
              ],
            ),
          );
        },
      ),
    );
  }
}

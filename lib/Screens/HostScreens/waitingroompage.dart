import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaitingRoomPage extends StatelessWidget {
  final String name;
  final String roomNumber;
  const WaitingRoomPage({
    super.key,
    required this.name,
    required this.roomNumber,
  });

  Stream<Map<String, dynamic>?> getAllData() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.collection("Rooms").doc(roomNumber).snapshots().map((
      documentSnapshot,
    ) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: StreamBuilder(
          stream: getAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("An Error Occured"));
            }
            final data = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Room Number: ${data["RoomNumber"]}",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Text(
                    "Player 1: ${data["Player 1"]}",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Text(
                    "Player 2: ${data["Player 2"]}",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Text(
                    "Player 3: ${data["Player 3"]}",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

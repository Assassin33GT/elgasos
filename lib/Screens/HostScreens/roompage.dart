import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgasos/Screens/HostScreens/waitingroompage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomPage extends StatelessWidget {
  final String name;
  const RoomPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    TextEditingController roomNumber = TextEditingController();

    void createRoom() async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection("Rooms").doc(roomNumber.text).set({
        "RoomNumber": roomNumber.text,
        "Player 1": name,
        "Player 2": null,
        "Player 3": null,
      });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Room Number",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: roomNumber,
                decoration: InputDecoration(
                  hintText: "Enter the room number",
                  hintStyle: TextStyle(fontSize: 17, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  filled: true,
                  fillColor: Colors.orange.shade300,
                ),
                style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade500, width: 2),
                ),
                onPressed: () async {
                  createRoom();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WaitingRoomPage(
                        name: name,
                        roomNumber: roomNumber.text,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

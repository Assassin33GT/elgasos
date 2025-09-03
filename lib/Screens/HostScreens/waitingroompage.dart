import 'package:elgasos/Screens/GameScreens/playeridentityscreen.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:elgasos/Widgets/showsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingRoomPage extends StatelessWidget {
  final String name;
  final String roomNumber;
  final int noOfPlayers;
  const WaitingRoomPage({
    super.key,
    required this.name,
    required this.roomNumber,
    required this.noOfPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            fixedSize: Size(double.maxFinite, 50),
          ),
          onPressed: () async {
            bool fullNot = await FirebaseData().roomFull(
              roomNumber,
              noOfPlayers,
            );

            if (fullNot) {
              goAnotherPage(
                context: context,
                page: PlayerIdentityScreen(
                  roomNumber: roomNumber,
                  playerName: name,
                ),
                isRoute: false,
              );
            } else {
              showSnackBar(context, "Wait for other players");
            }

            fullNot = false;
          },
          child: Center(
            child: Text(
              "Start Game",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: StreamBuilder(
          stream: FirebaseData().getRoomDataStream(roomNumber),
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
                  for (int i = 1; i <= noOfPlayers; i++)
                    Text(
                      data["Player $i"] == null
                          ? "Player $i: waiting..."
                          : "Player $i: ${data["Player $i"]}",
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

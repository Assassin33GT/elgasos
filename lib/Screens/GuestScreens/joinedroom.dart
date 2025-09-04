import 'package:elgasos/Screens/GameScreens/playeridentityscreen.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
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
    FirebaseData().updateRoomData(widget.roomNumber, widget.name);
  }

  void goAnother(bool isStarted) {
    goAnotherPage(
      context: context,
      page: PlayerIdentityScreen(
        roomNumber: widget.roomNumber,
        playerName: widget.name,
      ),
      isRoute: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseData().getRoomDataStream(widget.roomNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("No Data!"));
          }
          final data = snapshot.data!;

          if (data["Started"] == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              goAnother(true);
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Room Number: ${data["RoomNumber"]}",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                for (int i = 1; i <= data["NoOfPlayers"]; i++)
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
    );
  }
}

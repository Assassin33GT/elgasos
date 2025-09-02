import 'package:elgasos/Screens/HostScreens/waitingroompage.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/showsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomPage extends StatefulWidget {
  final String name;
  const RoomPage({super.key, required this.name});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int noOfPlayers = 3;
  List<int> optionsOfNumberOfPlayer = [3, 4, 5, 6, 7, 8];
  @override
  Widget build(BuildContext context) {
    TextEditingController roomNumber = TextEditingController();

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
              const SizedBox(height: 10),
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
              const SizedBox(height: 40),
              Text(
                "Number Of Players",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...optionsOfNumberOfPlayer.map((no) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            noOfPlayers = no;
                            setState(() {});
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: noOfPlayers == no
                                  ? Colors.deepOrangeAccent
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.deepOrange,
                                width: 2,
                              ),
                            ),
                            child: Center(child: Text(no.toString())),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade500, width: 2),
                ),
                onPressed: () async {
                  if (roomNumber.text.isNotEmpty) {
                    FirebaseData().createRoom(
                      noOfPlayers,
                      roomNumber.text,
                      widget.name,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WaitingRoomPage(
                          name: widget.name,
                          roomNumber: roomNumber.text,
                          noOfPlayers: noOfPlayers,
                        ),
                      ),
                    );
                  } else {
                    showSnackBar(context, "Enter the room number!");
                    setState(() {});
                  }
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

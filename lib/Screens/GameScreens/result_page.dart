import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatefulWidget {
  final String roomNumber;
  final String playerName;
  const ResultPage({
    super.key,
    required this.roomNumber,
    required this.playerName,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Map<String, dynamic>? roomData = {};
  List<String>? allImposters = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    roomData = await FirebaseData().getRoomData(widget.roomNumber);

    allImposters = await FirebaseData().getImposters(
      roomNumber: widget.roomNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "The Imposter is",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white70,
              ),
            ),
            ...allImposters!.map((imposter) {
              return Text(
                imposter,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:flutter/material.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("The imposter is"),
            ...allImposters!.map((imposter) {
              return Text(imposter);
            }),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgasos/Screens/GameScreens/startgame.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class PlayerIdentityScreen extends StatefulWidget {
  final String roomNumber;
  final String playerName;
  const PlayerIdentityScreen({
    super.key,
    required this.roomNumber,
    required this.playerName,
  });

  @override
  State<PlayerIdentityScreen> createState() => _GamescreenState();
}

class _GamescreenState extends State<PlayerIdentityScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? noOfQuestions = 0;

  @override
  void initState() {
    super.initState();
    startFunctions();
    // FirebaseData().giveQuestions(widget.roomNumber);
    startTimer();
  }

  Future<void> startFunctions() async {
    final names = await FirebaseData().getPlayersNames(widget.roomNumber);
    if (widget.playerName == names![0]) {
      await FirebaseData().botSendMessage(widget.roomNumber, "1");
      // startGiveIdentity();
    }
  }

  // Timer to go to next page
  void startTimer() async {
    noOfQuestions = await FirebaseData().getNumberOfQuestions(
      roomNumber: widget.roomNumber,
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        goAnotherPage(
          context: context,
          page: Startgame(
            playerName: widget.playerName,
            roomNumber: widget.roomNumber,
            noOfQuestions: noOfQuestions!,
          ),
          isRoute: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseData().getRoomDataStream(widget.roomNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error happend!"));
          }
          final Map<String, dynamic>? data = snapshot.data;

          return Center(
            child: Text(
              data![widget.playerName] == false ? data['Key'] : "جاسوس",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}

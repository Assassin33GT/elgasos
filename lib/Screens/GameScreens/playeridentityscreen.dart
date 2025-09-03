import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgasos/Screens/GameScreens/startgame.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    giveIdentity();
    createChat();
    // Timer to go to next page
    Timer.periodic(Duration(seconds: 5), (timer) {
      goAnotherPage(
        context: context,
        page: Startgame(
          playerName: widget.playerName,
          roomNumber: widget.roomNumber,
        ),
        isRoute: false,
      );
    });
  }

  void giveIdentity() async {
    final names = await FirebaseData().getRoomData(widget.roomNumber);
    await firestore.collection("Rooms").doc(widget.roomNumber).update({
      names!['Player 1']: randomFunction(),
      names["Player 2"]: randomFunction(),
      names["Player 3"]: randomFunction(),
    });
  }

  void createChat() async {
    Map<String, dynamic>? names = await FirebaseData().getRoomData(
      widget.roomNumber,
    );
    await firestore
        .collection("Rooms")
        .doc(widget.roomNumber)
        .collection("Chat")
        .doc("1")
        .set({
          "Msg": "${names!["Player 1"]} ask ${names["Player 2"]}",
          "Sender": "Bot",
        });
  }

  Stream<Map<String, dynamic>?> getIdentity() {
    return firestore.collection("Rooms").doc(widget.roomNumber).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return snapshot.data() as Map<String, dynamic>;
        }
        return null;
      },
    );
  }

  bool randomFunction() {
    final random = Random();
    return random.nextBool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: getIdentity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error happend!"));
          }
          final data = snapshot.data;

          return Center(
            child: Text(
              data![widget.playerName] == true ? "جاسوس" : "كلمة السر: بطيخ",
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

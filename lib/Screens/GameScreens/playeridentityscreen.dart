import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgasos/Widgets/getplayersname.dart';
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
  }

  void giveIdentity() async {
    final names = await getPlayersName(widget.roomNumber);
    await firestore.collection("Rooms").doc(widget.roomNumber).set({
      names!['Player 1']: randomFunction(),
      names["Player 2"]: randomFunction(),
      names["Player 3"]: randomFunction(),
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
        builder: (context, snapsot) {
          if (snapsot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapsot.hasError) {
            return Center(child: Text("An error happend!"));
          }
          final data = snapsot.data;

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

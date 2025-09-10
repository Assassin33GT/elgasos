import 'package:elgasos/Screens/GameScreens/startgame.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChoosePlayer extends StatefulWidget {
  final String playerName;
  final String roomNumber;
  final int noOfQuestions;
  const ChoosePlayer({
    super.key,
    required this.roomNumber,
    required this.playerName,
    required this.noOfQuestions,
  });

  @override
  State<ChoosePlayer> createState() => _ChoosePlayerState();
}

class _ChoosePlayerState extends State<ChoosePlayer> {
  String asker = "";

  @override
  Widget build(BuildContext context) {
    String id = "";
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: StreamBuilder(
        stream: FirebaseData().getPlayersAskStream(widget.roomNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error happend!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No messages yet."));
          }

          final List<Map<String, dynamic>> playersAsk = snapshot.data!;
          List<String> playersNames = [];

          playersAsk.forEach((playerAsk) {
            if (playerAsk['Asker'] == asker && playerAsk['Will Ask'] != null) {
              if (playerAsk['Will Ask'] == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  goAnotherPage(
                    context: context,
                    page: Startgame(
                      playerName: widget.playerName,
                      roomNumber: widget.roomNumber,
                      noOfQuestions: widget.noOfQuestions + 1,
                    ),
                    isRoute: false,
                  );
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  goAnotherPage(
                    context: context,
                    page: ChoosePlayer(
                      roomNumber: widget.roomNumber,
                      playerName: widget.playerName,
                      noOfQuestions: widget.noOfQuestions,
                    ),
                    isRoute: false,
                  );
                });
              }
            }
            if (playerAsk['Will Ask'] == null && asker == "") {
              asker = playerAsk['Asker'];
              id = playerAsk['Id'];
            }
            if (playerAsk['Asker'] != widget.playerName) {
              playersNames.add(playerAsk['Asker']);
            }
          });
          playersNames.add("No One");

          return asker == widget.playerName
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Which Player you want to ask?",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ...playersNames.map((player) {
                        print("map: $id");

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              print("Enter: $id");
                              FirebaseData().updatePlayerAsk(
                                answerer: player != "No One" ? player : "",
                                id: id,
                                roomNumber: widget.roomNumber,
                                willAsk: player != "No One" ? true : false,
                              );
                              if (player != "No One") {
                                FirebaseData().playerMakeBotSendMessage(
                                  widget.roomNumber,
                                  widget.playerName,
                                  player,
                                );
                              }
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    player,
                                    style: GoogleFonts.varela(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    "Waiting $asker to choose...",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white70,
                    ),
                  ),
                );
        },
      ),
    );
  }
}

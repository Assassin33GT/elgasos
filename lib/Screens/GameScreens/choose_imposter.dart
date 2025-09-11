import 'package:elgasos/Screens/GameScreens/result_page.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseImposter extends StatefulWidget {
  final String roomNumber;
  final String playerName;
  const ChooseImposter({
    super.key,
    required this.roomNumber,
    required this.playerName,
  });

  @override
  State<ChooseImposter> createState() => _ChooseImposterState();
}

class _ChooseImposterState extends State<ChooseImposter> {
  String choosenPlayer = "";
  Color getColor(String playerName) {
    if (choosenPlayer == "") {
      return Colors.orangeAccent;
    } else if (choosenPlayer == playerName) {
      return Colors.lightGreen;
    } else {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String id = "";
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: StreamBuilder(
        stream: FirebaseData().getChoosePlayerStream(widget.roomNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error happend!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No messages yet."));
          }
          final List<Map<String, dynamic>> choosePlayer = snapshot.data!;
          List<String> playersNames = [];
          int counter = 0;
          choosePlayer.forEach((player) {
            if (widget.playerName != player['Player']) {
              playersNames.add(player['Player']);
            }
            if (widget.playerName == player['Player']) {
              id = player['Id'];
            }
            if (player['Choosen Player'] != "") {
              counter++;
            }

            if (choosePlayer.length == counter) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                goAnotherPage(
                  context: context,
                  page: ResultPage(
                    roomNumber: widget.roomNumber,
                    playerName: widget.playerName,
                  ),
                  isRoute: false,
                );
              });
            }
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Choose The Imposter",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                ...playersNames.map((player) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        if (choosenPlayer == "") {
                          FirebaseData().updateChoosePlayer(
                            roomNumber: widget.roomNumber,
                            id: id,
                            choosenPlayer: player,
                          );
                          choosenPlayer = player;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: getColor(player),
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
          );
        },
      ),
    );
  }
}

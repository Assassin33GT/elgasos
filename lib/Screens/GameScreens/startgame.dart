import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Startgame extends StatefulWidget {
  final String playerName;
  final String roomNumber;
  const Startgame({
    super.key,
    required this.playerName,
    required this.roomNumber,
  });

  @override
  State<Startgame> createState() => _StartgameState();
}

class _StartgameState extends State<Startgame> {
  TextEditingController message = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? no = 1;
  String? _currentAsker;
  String? _currentAnswerer;
  bool canSend = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void updateBool({
      bool? asked,
      bool? answered,
      required String index,
    }) async {
      await firestore
          .collection("Rooms")
          .doc(widget.roomNumber)
          .collection("Chat")
          .doc(index)
          .update({
            if (asked != null) "Asked": asked,
            if (answered != null) "Answered": answered,
          });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseData().getAllMessagesStream(widget.roomNumber),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("An error happend!"));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }
                final messages = snapshot.data!.docs;

                bool newCanSend = false;
                if (_currentAsker == widget.playerName && no! % 2 == 1) {
                  newCanSend = true;
                } else if (_currentAnswerer == widget.playerName &&
                    no! % 2 == 0) {
                  newCanSend = true;
                }

                // ✅ only call setState if value actually changed
                if (newCanSend != canSend) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      canSend = newCanSend;
                    });
                  });
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isCurrentPlayer =
                          msg['Sender'] == widget.playerName;
                      no = messages.length;

                      // To know asker and who should answer
                      for (final msg in messages.reversed) {
                        if (msg['Asker'] != null && msg['Answerer'] != null) {
                          // 3. UPDATE THE STATE (and trigger a rebuild)
                          if (messages.length % 2 == 1 &&
                              msg['Asked'] == true &&
                              msg['Sender'] == "Bot" &&
                              msg['Answered'] == false &&
                              messages[no! - 1]['Sender'] != "Bot") {
                            print("Answerer in");

                            updateBool(
                              index: (index + 1).toString(),
                              answered: true,
                            );
                          }
                          if (_currentAsker != msg['Asker'] &&
                              msg['Asked'] == false &&
                              msg['Sender'] == "Bot" &&
                              messages.length % 2 == 1) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _currentAsker = msg['Asker'];
                                no = messages.length;
                              });
                            });
                          } else if (_currentAnswerer != msg['Answerer'] &&
                              msg['Asked'] == true &&
                              msg['Answered'] == false &&
                              msg['Sender'] == "Bot" &&
                              messages.length % 2 == 0) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _currentAnswerer = msg['Answerer'];
                                no = messages.length;
                              });
                            });
                          }
                          break; // Found the most recent one, break the loop.
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: isCurrentPlayer
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentPlayer
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['Msg'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['Sender'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color.fromARGB(
                                      255,
                                      94,
                                      91,
                                      91,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: message,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if (message.text.isNotEmpty) {
                            // To save Message in the firestore
                            FirebaseData().sendMessage(
                              noOfMessages: no! + 1,
                              message: message.text,
                              playerName: widget.playerName,
                              roomNumber: widget.roomNumber,
                            );

                            if (_currentAsker == widget.playerName) {
                              await firestore
                                  .collection("Rooms")
                                  .doc(widget.roomNumber)
                                  .collection("Chat")
                                  .doc((no! + 1).toString())
                                  .update({"Asked": true});
                            }

                            if (_currentAnswerer == widget.playerName) {
                              await firestore
                                  .collection("Rooms")
                                  .doc(widget.roomNumber)
                                  .collection("Chat")
                                  .doc((no! + 1).toString())
                                  .update({"Answered": true});
                            }
                            message.clear();
                          }
                        },
                        icon: Icon(Icons.send_rounded),
                      ),
                      enabled: canSend,
                      hintText: "Enter a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      filled: true,
                      fillColor: Colors.orange.shade300,
                    ),
                    style: GoogleFonts.aBeeZee(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

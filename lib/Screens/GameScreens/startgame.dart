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
  String? _activeBotId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      print("asd:$_currentAnswerer");

                      for (final msg in messages) {
                        print("asd:$_currentAnswerer");
                        print("asd2:$_currentAsker");

                        if (msg['Sender'] == "Bot" &&
                            _activeBotId != msg.id &&
                            (msg['Asked'] == false ||
                                msg['Answered'] == false)) {
                          print("asd:$_currentAnswerer");
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _activeBotId = msg
                                  .id; // <-- Save the "current round" Bot message
                            });
                          });
                          break; // found the active Bot doc, stop searching
                        }
                      }

                      // To know asker and who should answer
                      for (final msg in messages) {
                        if (msg['Asker'] != widget.playerName &&
                            msg['Sender'] == "Bot") {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _currentAsker = null;
                          });
                        }
                        if (msg['Sender'] == "Bot" &&
                            msg['Asked'] == true &&
                            msg['Answered'] == true &&
                            _currentAnswerer != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _currentAsker = null;
                              _currentAnswerer = null;
                              canSend = false;
                              newCanSend = false;
                              no = messages.length;
                            });
                          });
                        }

                        if (msg['Asker'] != null && msg['Answerer'] != null) {
                          // Enable the Input Controller for user
                          if (_currentAsker == widget.playerName &&
                              msg['Asked'] == false) {
                            newCanSend = true;
                            print("New Can Send: ${_currentAsker}");
                          } else if (_currentAnswerer == widget.playerName &&
                              msg['Asked'] == true &&
                              msg['Answered'] == false) {
                            newCanSend = true;
                            print("New Can Send: $newCanSend");
                          } else {
                            newCanSend = false;
                          }

                          // ✅ only call setState if value actually changed
                          if (newCanSend != canSend) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                canSend = newCanSend;
                              });
                            });
                          }

                          if (_currentAsker != msg['Asker'] &&
                              msg['Asked'] == false &&
                              msg['Sender'] == "Bot" &&
                              widget.playerName == msg['Asker']) {
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
                              widget.playerName == msg['Answerer']) {
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

                            // Change in database
                            if (_currentAsker == widget.playerName) {
                              await firestore
                                  .collection("Rooms")
                                  .doc(widget.roomNumber)
                                  .collection("Chat")
                                  .doc(_activeBotId)
                                  .update({"Asked": true});
                            }

                            // Change in database
                            if (_currentAnswerer == widget.playerName) {
                              await firestore
                                  .collection("Rooms")
                                  .doc(widget.roomNumber)
                                  .collection("Chat")
                                  .doc(_activeBotId)
                                  .update({"Answered": true});

                              // Send Bot Message after Answerer send Message
                              await FirebaseData().botSendMessage(
                                widget.roomNumber,
                                (no! + 1).toString(),
                              );
                              // setState(() {
                              //   _currentAnswerer = null;
                              //   _currentAsker = null;
                              // });
                            }
                            setState(() {});
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

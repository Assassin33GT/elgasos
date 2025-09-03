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
  Future<int?>? noOfMessages;

  @override
  void initState() {
    super.initState();
    noOfMessages = Future.value(getChatIds());
  }

  Future<int?> getChatIds() async {
    QuerySnapshot snapshot = await firestore
        .collection("Rooms")
        .doc(widget.roomNumber)
        .collection("Chat")
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.length;
    }
    return null;
  }

  void sendMessage(int? no) async {
    if (message.text.isEmpty) return;
    no = no! + 1;
    await firestore
        .collection("Rooms")
        .doc(widget.roomNumber)
        .collection("Chat")
        .doc(no.toString())
        .set({"Msg": message.text, "Sender": widget.playerName});

    noOfMessages = Future.value(getChatIds());
    message.clear();
  }

  Stream<Map<String, dynamic>>? getChatData() {
    firestore
        .collection("Rooms")
        .doc(widget.roomNumber)
        .collection("Chat")
        .snapshots()
        .map((snapsot) {
          if (snapsot.docs.isNotEmpty) {
            List<String> data = [];

            snapsot.docs.forEach((doc) {
              data.add(doc.id);
            });
            return data;
          }
        });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          controller: message,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () async {
                sendMessage(await noOfMessages!);
              },
              icon: Icon(Icons.send_rounded),
            ),
            hintText: "Enter a message...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            filled: true,
            fillColor: Colors.orange.shade300,
          ),
          style: GoogleFonts.aBeeZee(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder(
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 78.0),
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isCurrentPlayer = msg['Sender'] == widget.playerName;
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
                              color: const Color.fromARGB(255, 94, 91, 91),
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
    );
  }
}

import 'package:elgasos/Screens/GuestScreens/joinedroom.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:elgasos/Widgets/showsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Joinroom extends StatelessWidget {
  final String name;
  const Joinroom({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    void goAnother(String roomNumber, bool fullNot) {
      if (fullNot == false) {
        goAnotherPage(
          context: context,
          page: Joinedroom(roomNumber: roomNumber, name: name),
          isRoute: true,
        );
      } else {
        showSnackBar(context, "Room is Full!");
      }
    }

    void isFull(String roomNumber) async {
      final fullNot = await FirebaseData().roomFull(roomNumber);
      goAnother(roomNumber, fullNot);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 46, 112),
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseData().getAllRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("No Data!"));
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...data.map((roomData) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              isFull(roomData['RoomNumber']);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Container(
                                      height: double.infinity,
                                      width: 50,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          size: 60,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Room Name: ${roomData['RoomNumber']}",
                                        style: GoogleFonts.varela(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Number of Players: ${roomData['NoOfPlayers']}",
                                        style: GoogleFonts.varela(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Number of Imposters: ${roomData['NoOfImposters']}",
                                        style: GoogleFonts.varela(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

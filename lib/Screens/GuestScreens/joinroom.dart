import 'package:elgasos/Screens/GuestScreens/joinedroom.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:flutter/material.dart';

class Joinroom extends StatelessWidget {
  final String name;
  const Joinroom({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...data.map((roomNumber) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              Joinedroom(roomNumber: roomNumber, name: name),
                        ),
                      );
                    },
                    child: Text(roomNumber),
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

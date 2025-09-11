import 'package:elgasos/Screens/homepage.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Namepage extends StatelessWidget {
  const Namepage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 41, 91),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Guest Name*",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  hintText: "Enter your name",
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
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade500, width: 2),
                ),
                onPressed: () {
                  goAnotherPage(
                    context: context,
                    page: Homepage(name: name.text),
                    isRoute: false,
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

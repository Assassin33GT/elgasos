import 'package:elgasos/Screens/GameScreens/playeridentityscreen.dart';
import 'package:elgasos/Widgets/firebasedata.dart';
import 'package:elgasos/Widgets/goAnotherPage.dart';
import 'package:elgasos/Widgets/showsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingRoomPage extends StatefulWidget {
  final String name;
  final String roomNumber;
  final int noOfPlayers;
  const WaitingRoomPage({
    super.key,
    required this.name,
    required this.roomNumber,
    required this.noOfPlayers,
  });

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage>
    with TickerProviderStateMixin {
  int flag = 0;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> keys = [
    "بطيخ",
    "مكرونة بشمل",
    "فراخ بانيه",
    "طعميه",
    "كشري",
    "كبسة",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Call the Functions that give players the key or imposter
  Future<void> startGiveIdentity() async {
    final getRoomData = await FirebaseData().getRoomData(widget.roomNumber);
    FirebaseData().playersAskAndChoosePlayer(roomNumber: widget.roomNumber);
    FirebaseData().giveIdentity(
      roomNumber: widget.roomNumber,
      noOfPlayers: getRoomData!['NoOfPlayers'],
      noOfImposters: getRoomData['NoOfImposters'],
    );
  }

  void goAnother(bool fullNot) async {
    if (fullNot) {
      setState(() {
        flag++;
      });
      keys.shuffle();
      await FirebaseData().giveQuestions(widget.roomNumber);
      await FirebaseData().gameStarted(
        roomNumber: widget.roomNumber,
        key: keys[0],
      );
      await startGiveIdentity();

      goAnotherPage(
        context: context,
        page: PlayerIdentityScreen(
          roomNumber: widget.roomNumber,
          playerName: widget.name,
        ),
        isRoute: false,
      );
    } else {
      showSnackBar(context, "Wait for other players");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF24243e), Color(0xFF302B63)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),

              // Main Content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: StreamBuilder(
                    stream: FirebaseData().getRoomDataStream(widget.roomNumber),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      } else if (snapshot.hasError) {
                        return _buildErrorState();
                      }
                      final data = snapshot.data!;
                      return _buildRoomContent(data);
                    },
                  ),
                ),
              ),

              // Start Game Button
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Animated Logo/Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.groups,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            "Waiting Room",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Get ready for an amazing game!",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "Loading room data...",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            "An Error Occurred",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please try again later",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Room Number Card
          _buildRoomNumberCard(data),

          const SizedBox(height: 30),

          // Players List
          _buildPlayersList(data),

          const SizedBox(height: 20),

          // Game Status
          if (flag == 1) _buildGameStatus(),
        ],
      ),
    );
  }

  Widget _buildRoomNumberCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.meeting_room, size: 40, color: Colors.white),
          const SizedBox(height: 15),
          Text(
            "Room Code",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data["RoomNumber"] ?? "Loading...",
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Players (${widget.noOfPlayers})",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        ...List.generate(widget.noOfPlayers, (index) {
          final playerNumber = index + 1;
          final playerName = data["Player $playerNumber"];
          final isPlayerJoined = playerName != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildPlayerCard(playerNumber, playerName, isPlayerJoined),
          );
        }),
      ],
    );
  }

  Widget _buildPlayerCard(int playerNumber, String? playerName, bool isJoined) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isJoined
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isJoined
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Player Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isJoined
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.withOpacity(0.3),
            ),
            child: Icon(
              isJoined ? Icons.person : Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Player $playerNumber",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isJoined ? playerName! : "Waiting...",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isJoined ? Colors.white : Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isJoined ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "Game will start soon...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  bool fullNot = await FirebaseData().roomFull(
                    widget.roomNumber,
                  );
                  goAnother(fullNot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      "Start Game",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
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
  }
}

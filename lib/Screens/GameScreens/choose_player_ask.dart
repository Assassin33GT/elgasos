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

class _ChoosePlayerState extends State<ChoosePlayer>
    with TickerProviderStateMixin {
  List<String>? playersNames = [];
  int roomId = 0;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();

    getAllData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void getAllData() async {
    roomId = await FirebaseData().getRoomId(roomNumber: widget.roomNumber);
    playersNames = await FirebaseData().getPlayersNames(widget.roomNumber);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String asker = "";

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
          child: StreamBuilder(
            stream: FirebaseData().getFirstPlayersAskStream(
              id: roomId.toString(),
              roomNumber: widget.roomNumber,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              } else if (snapshot.hasError) {
                return _buildErrorState();
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }
              final Map<String, dynamic> playersAsk = snapshot.data!;

              if (playersAsk['Will Ask'] != null) {
                if (playersAsk['Will Ask'] == true) {
                  FirebaseData().updateRoomId(
                    roomNumber: widget.roomNumber,
                    id: ++roomId,
                  );
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
                    FirebaseData().updateRoomId(
                      roomNumber: widget.roomNumber,
                      id: ++roomId,
                    );
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

              if (playersAsk['Will Ask'] == null && asker == "") {
                asker = playersAsk['Asker'];
              }

              for (int i = 0; i < playersNames!.length; i++) {
                if (playersNames![i] == asker) {
                  playersNames!.remove(asker);
                }
              }
              if (!playersNames!.contains("No One"))
                playersNames!.add("No One");

              return playersAsk['Asker'] == widget.playerName
                  ? _buildPlayerSelectionView(playersAsk)
                  : _buildWaitingView(playersAsk);
            },
          ),
        ),
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
            "Loading game data...",
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
            "Connection Error",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Unable to load game data",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.white54),
          const SizedBox(height: 20),
          Text(
            "No Game Data",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Waiting for game to start...",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelectionView(Map<String, dynamic> playersAsk) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Section
            _buildHeader(),

            const SizedBox(height: 40),

            // Player Selection Card
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPlayerSelectionCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView(Map<String, dynamic> playersAsk) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo/Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            "Waiting for ${playersAsk['Asker']}",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "to choose a player to ask...",
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo/Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.quiz, size: 50, color: Colors.white),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          "Choose a Player",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Who do you want to ask?",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSelectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Select a player to ask:",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: playersNames!.map((player) {
              return _buildPlayerButton(player);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerButton(String player) {
    final isNoOne = player == "No One";
    return Container(
      width: 150,
      height: 60,
      decoration: BoxDecoration(
        gradient: isNoOne
            ? const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
              )
            : const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isNoOne ? Colors.red : Colors.green).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FirebaseData().updatePlayerAsk(
              answerer: player != "No One" ? player : "",
              id: roomId.toString(),
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
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNoOne ? Icons.person_off : Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    player,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

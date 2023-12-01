import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import '../models/dialogue.dart';
import '../services/firebase_service.dart';
import '../services/dialogue_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final DialogueService _dialogueService = DialogueService();
  Future<Dialogue>? _dialogueFuture;
  int _currentLevel = 1;
  int _rewardPoints = 0;
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _currentLevel = await _dialogueService.getCurrentLevel();
    _rewardPoints = await _dialogueService.getRewardPoints();
    _dialogueFuture = _fetchDialogue(_currentLevel);
    setState(() {});
  }

  Future<Dialogue> _fetchDialogue(int level) async {
    return _firebaseService.getDialogue(level);
  }

  void _handleAnswer(int selectedOptionIndex, Dialogue dialogue) async {
    final isCorrect = selectedOptionIndex == dialogue.rightOptionIndex;
    setState(() {
      _selectedOptionIndex = selectedOptionIndex;
    });

    if (isCorrect) {
      await _dialogueService.addRewardPoints(10);
      int updatedPoints = await _dialogueService.getRewardPoints();
      setState(() {
        _rewardPoints = updatedPoints;
      });
      _showCongratulationsPopup();
    } else {
      // Implement failure animation or effect
      _showWrongAnswerPopup(dialogue);
    }
  }

  void _showCongratulationsPopup() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside of it
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations!",
                  style: GoogleFonts.bitter(
                      fontSize: 20, color: Colors.blueGrey[900]))
              .centered(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset("assets/images/trophy.png"),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900]),
              onPressed: () {
                Navigator.of(context).pop(
                    'next'); // Close the dialog and pass back 'next' as the result.
              },
              child: Text("Next",
                  style: GoogleFonts.bitter(fontSize: 20, color: Colors.white)),
            ).centered(),
          ],
        );
      },
    ).then((result) {
      // Since barrierDismissible is false, result will not be null when dismissed by tapping outside
      // 'next' will be passed back when the "Next" button is pressed.
      if (result == 'next' || result == null) {
        _loadNextLevel(); // Load the next level
      }
    });
  }

  void _showWrongAnswerPopup(Dialogue dialogue) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside of it
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Oops! Wrong Answer",
            style:
                GoogleFonts.bitter(fontSize: 20, color: Colors.blueGrey[900]),
          ).centered(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "The correct answer was: ${dialogue.options[dialogue.rightOptionIndex]}",
                style: GoogleFonts.bitter(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Adds space between text and image
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _loadNextLevel(); // Load the next level
              },
              child: Text(
                "OK",
                style: GoogleFonts.bitter(fontSize: 20, color: Colors.white),
              ),
            ).centered(),
          ],
        );
      },
    );
  }

  void _loadNextLevel() async {
    // Logic to load the next level
    _currentLevel++;
    _dialogueFuture = _fetchDialogue(_currentLevel);
    _selectedOptionIndex = null; // Reset the selected option
    await _dialogueService.incrementLevel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("assets/images/back.png"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HStack([
              Text(
                '$_currentLevel',
                style: GoogleFonts.bitter(fontSize: 20, color: Colors.white),
              ).centered(), // Center the text within the VStack
            ])
                .box
                .roundedLg
                .shadowLg
                .make()
                .pOnly(right: 10, left: 10)
                .glassMorphic() // Styling the badge with a box
          ],
        ),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 0,
        actions: <Widget>[
          HStack([
            Image.asset(
              "assets/images/coin.png",
              height: 24.0,
              width: 24.0,
            ),
            const SizedBox(width: 8),
            Text('$_rewardPoints',
                style: GoogleFonts.bitter(fontSize: 20, color: Colors.white)),
          ])
              .pOnly(right: 10, left: 10)
              .backgroundColor(Colors.blueGrey.shade900)
              .glassMorphic(),
        ],
      ),
      body: FutureBuilder<Dialogue>(
        future: _dialogueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Dialogue dialogue = snapshot.data!;
            return _buildGameScreen(dialogue);
          } else if (snapshot.hasError) {
            return Center(
                child: const Text('Wow! you finished all the Levels')
                    .text
                    .textStyle(
                        GoogleFonts.bitter(fontSize: 25, color: Colors.white))
                    .red600
                    .xl2
                    .make());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildGameScreen(Dialogue dialogue) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blueGrey.shade800, // Start color of the gradient
            Colors.blueGrey.shade800, // End color of the gradient
          ],
        ),
      ),
      child: VStack([
        // Image container
        VxBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: dialogue.imageUrl,
              fit: BoxFit.fill,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error_outline, size: 50, color: Colors.white),
            ),
          ),
        )
            .shadowXl
            .color(Colors.transparent)
            .height(context.percentHeight * 60)
            .make()
            .p16(),
        // Options grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 0, // Add space between columns
            mainAxisSpacing: 8, // Add space between rows
          ),
          itemCount: dialogue.options.length,
          itemBuilder: (context, index) {
            final option = dialogue.options[index];
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = dialogue.rightOptionIndex == index;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: isSelected
                    ? isCorrect
                        ? Vx.green500
                        : Vx.red500
                    : Colors.white
                        .withAlpha(200), // Semi-transparent for glass effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4), // changes position of shadow
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  textStyle: GoogleFonts.bitter(fontSize: 18),
                  elevation:
                      0, // Remove elevation since we're using custom shadow
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () => _handleAnswer(index, dialogue),
                child: Text(
                  option,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            ).px4().py2(); // Add padding to create space around each grid item
          },
        ).expand(),
      ]),
    );
  }
}

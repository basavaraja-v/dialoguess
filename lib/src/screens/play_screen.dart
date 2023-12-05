import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import '../models/dialogue.dart';
import '../services/firebase_service.dart';
import '../services/dialogue_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/audio_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class PlayScreen extends StatefulWidget {
  final VoidCallback onUpdate;
  const PlayScreen({super.key, required this.onUpdate});

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
  bool _isImageLoaded = false;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _confettiController.play();
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
      // AudioManager.playSFX('correctans.mp3');
      _showCongratulationsPopup();
      widget.onUpdate();
    } else {
      // Implement failure animation or effect
      _showWrongAnswerPopup(dialogue);
      AudioManager.playSFX('wrongans.mp3');
    }
  }

  @override
  void dispose() {
    widget.onUpdate(); // Also call onUpdate when PlayScreen is disposed
    _confettiController.dispose();
    super.dispose();
  }

  void _showCongratulationsPopup() {
    // Start playing confetti
    _confettiController.play();
    bool tengthLevel = (_currentLevel % 10) == 0;
    tengthLevel
        ? AudioManager.playSFX('cheers.mp3')
        : AudioManager.playSFX('blast.mp3');

    // Preload the next level
    _loadNextLevel();
    List<String> titles = ["Great!", "Brilliant!", "Awesome!", "Well Done!"];
    Random random = Random();
    String popupTitle = tengthLevel
        ? "Congratulations!"
        : titles[random.nextInt(titles.length)];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            popupTitle,
            style: GoogleFonts.bitter(
                fontSize: 20,
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold),
          ).centered(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                "assets/images/coins.png",
                height: 100.0,
                width: 100.0,
              ),
              const SizedBox(
                height: 20,
              ),
              tengthLevel
                  ? // Show trophy every 10th level
                  Image.asset("assets/images/trophy.png")
                  :
                  // Lottie animation
                  Lottie.asset('assets/animations/confetti.json'),
              // Confetti widget
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                // Other confetti properties
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900]),
              onPressed: () {
                AudioManager.playSFX('click.mp3');
                Navigator.of(context).pop('next');
                _confettiController.stop(); // Stop the confetti animation
              },
              child: Text("Next",
                  style: GoogleFonts.bitter(fontSize: 20, color: Colors.white)),
            ).centered(),
          ],
        );
      },
    ).then((result) {
      if (result == 'next' || result == null) {
        // Just close the popup, next level is already loaded
      }
    });
  }

  void _showWrongAnswerPopup(Dialogue dialogue) {
    _loadNextLevel(); // Load the next level

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
                AudioManager.playSFX('click.mp3');
                Navigator.of(context).pop(); // Close the dialog
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
    _isImageLoaded = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("assets/images/back.png"),
          onPressed: () {
            AudioManager.playSFX('click.mp3');
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HStack([
              Text(
                '$_currentLevel',
                style: GoogleFonts.bitter(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
            AnimatedFlipCounter(
              value: _rewardPoints, // Pass in your reward points variable
              duration: const Duration(milliseconds: 4000), // Animation speed
              textStyle: GoogleFonts.bitter(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    .textStyle(GoogleFonts.bitter(fontSize: 25))
                    .green600
                    .xl2
                    .make());
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(255, 44, 56, 61),
            ));
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
            Colors.blueGrey.shade800,
            Colors.blueGrey.shade800,
          ],
        ),
      ),
      child: VStack([
        FutureBuilder<Dialogue>(
          future: _dialogueFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildImageShimmerEffect(context);
            }
            if (snapshot.hasData) {
              return CachedNetworkImage(
                imageUrl: dialogue.imageUrl,
                imageBuilder: (context, imageProvider) =>
                    _buildImageContainer(context, imageProvider),
                placeholder: (context, url) =>
                    _buildImageShimmerEffect(context),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error_outline, size: 50, color: Colors.white),
              );
            }
            return Text("Error loading image");
          },
        ),
        _isImageLoaded
            ? _buildOptionsGrid(dialogue)
            : _buildOptionShimmerEffect(),
      ]),
    );
  }

  Widget _buildImageContainer(
      BuildContext context, ImageProvider imageProvider) {
    if (!_isImageLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isImageLoaded = true;
        });
      });
    }
    return VxBox(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image(image: imageProvider, fit: BoxFit.fill),
      ),
    ).shadowXl.color(Colors.transparent).make().p16();
  }

  Widget _buildOptionsGrid(Dialogue dialogue) {
    return LayoutBuilder(builder: (context, constraints) {
      // Adjust the aspect ratio based on the screen width
      double width = constraints.maxWidth;
      double childAspectRatio =
          width > 600 ? 4 : 3; // Wider aspect ratio for larger screens

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: childAspectRatio, // Adjusted aspect ratio
          crossAxisSpacing: 0,
          mainAxisSpacing: 8,
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
                  : Colors.white,
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
                style:
                    TextStyle(color: isSelected ? Colors.white : Colors.black),
              ),
            ),
          ).px2(); // Add padding to create space around each grid item
        },
      );
    }).expand();
  }

  Widget _buildImageShimmerEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.blueGrey[700]!,
      highlightColor: Colors.blueGrey[500]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[900],
          borderRadius: BorderRadius.circular(30),
        ),
        height: context.percentHeight * 60,
        width: double.infinity,
      ),
    ).p16();
  }

  Widget _buildOptionShimmerEffect() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      // Adjust to match the aspect ratio of actual options
      children: List.generate(4, (index) {
        // Create 4 placeholders
        return Shimmer.fromColors(
          baseColor: Colors.blueGrey[700]!,
          highlightColor: Colors.blueGrey[500]!,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    ).px24().py20();
  }
}

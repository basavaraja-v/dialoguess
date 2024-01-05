import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../models/dialogue.dart';
import '../services/firebase_service.dart';
import '../services/dialogue_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/audio_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../games_services/games_services.dart';
import '../ads/rewarded_ad_manager.dart';

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
  late GamesServicesController gamesServicesController;
  late RewardedAdManager _rewardedAdManager;
  List<bool> _struckOptions = [];

  @override
  void initState() {
    super.initState();
    _confettiController.play();
    _loadInitialData();
    _loadStruckOptions();
    gamesServicesController = GamesServicesController();
    _rewardedAdManager = RewardedAdManager(
      onReward: (int rewardAmount) {
        // Handle the reward here, e.g., increment coins
        print('User earned reward: $rewardAmount');
      },
    );
    _rewardedAdManager.loadRewardedAd();
  }

  Future<void> _loadInitialData() async {
    _currentLevel = await _dialogueService.getCurrentLevel();
    _rewardPoints = await _dialogueService.getRewardPoints();
    _dialogueFuture = _fetchDialogue(_currentLevel);
    // Reset struck-out options for the new level
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _struckOptions = List.filled(4, false); // Reset struck-out options
      prefs.setStringList(
          'struckOptions', _struckOptions.map((e) => e.toString()).toList());
    });
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
      _showCongratulationsPopup();
      widget.onUpdate();
    } else {
      // await _dialogueService.minusRewardPoints(10);
      _showWrongAnswerPopup(dialogue);
      AudioManager.playSFX('wrongans.mp3');
    }

    int updatedPoints = await _dialogueService.getRewardPoints();
    setState(() {
      _rewardPoints = updatedPoints;
    });

    await gamesServicesController.submitLeaderboardScore(_rewardPoints);
  }

  @override
  void dispose() {
    widget.onUpdate(); // Also call onUpdate when PlayScreen is disposed
    _confettiController.dispose();
    super.dispose();
  }

  void _showCongratulationsPopup() {
    _confettiController.play();
    bool tengthLevel = (_currentLevel % 10) == 0;
    tengthLevel
        ? AudioManager.playSFX('cheers.mp3')
        : AudioManager.playSFX('blast.mp3');

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
        var screenSize = MediaQuery.of(context).size;
        final adsControllerAvailable = context.watch<AdsController?>() != null;
        final adsRemoved =
            context.watch<InAppPurchaseController?>()?.adRemoval.active ??
                false;
        return Dialog(
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Center(
                  // Use Center to align the column vertically
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Use min size for the column
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the content
                    children: <Widget>[
                      // Your existing widgets and layout go here
                      const SizedBox(height: 50),
                      Text(popupTitle,
                          style: GoogleFonts.bitter(
                              fontSize: 24,
                              color: Colors.blueGrey[900],
                              fontWeight: FontWeight.bold)),
                      // Image.asset(
                      //   "assets/images/coins.png",
                      //   height: 100.0,
                      //   width: 100.0,
                      // ),
                      // Confetti widget
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        // Other confetti properties
                      ),
                      tengthLevel
                          ? Image.asset("assets/images/trophy.png",
                              width: 200, height: 200)
                          : Lottie.asset('assets/animations/confetti.json',
                              width: 200, height: 200),
                      const SizedBox(height: 10),
                      if (adsControllerAvailable && !adsRemoved) ...[
                        const BannerAdWidget(),
                      ],
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blueGrey[900],
                onPressed: () {
                  AudioManager.playSFX('click.mp3');
                  Navigator.of(context).pop('next');
                  _confettiController.stop();
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    ).then((result) {
      if (result == 'next' || result == null) {
        // Close the popup, next level is already loaded
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
        final screenSize = MediaQuery.of(context).size;
        final adsControllerAvailable = context.watch<AdsController?>() != null;
        final adsRemoved =
            context.watch<InAppPurchaseController?>()?.adRemoval.active ??
                false;

        return Dialog(
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      Text(
                        "Oops! Wrong Answer",
                        style: GoogleFonts.bitter(
                            fontSize: 24, color: Colors.blueGrey[900]),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "The correct answer was: ${dialogue.options[dialogue.rightOptionIndex]}",
                        style: GoogleFonts.bitter(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (adsControllerAvailable && !adsRemoved) ...[
                        const BannerAdWidget(),
                      ],
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blueGrey[900],
                onPressed: () {
                  AudioManager.playSFX('click.mp3');
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _loadNextLevel() async {
    // Logic to load the next level
    _currentLevel++;
    _dialogueFuture = _fetchDialogue(_currentLevel);
    _selectedOptionIndex = null; // Reset the selected option
    // Reset struck-out options for the new level
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _struckOptions = List.filled(4, false); // Reset struck-out options
      prefs.setStringList(
          'struckOptions', _struckOptions.map((e) => e.toString()).toList());
    });
    await _dialogueService.incrementLevel();
    _isImageLoaded = false;
    setState(() {});
  }

  void _useHint() {
    if (_rewardPoints < 10) {
      _showRewardedAd();
    }
    _strikeOutWrongOption();
  }

  void _strikeOutWrongOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _dialogueService.minusRewardPoints(10);
    int updatedPoints = await _dialogueService.getRewardPoints();

    setState(() {
      _rewardPoints = updatedPoints;

      // Fetch the future's data and then process the striking out logic
      _dialogueFuture!.then((dialogue) {
        // Ensure there are less than 3 options struck out
        if (_struckOptions.where((element) => element).length < 3) {
          List<int> wrongOptionsIndices = List.generate(4, (index) => index)
              .where((index) => index != dialogue.rightOptionIndex)
              .toList();

          // Remove already struck options
          wrongOptionsIndices.removeWhere((index) => _struckOptions[index]);

          // If there are wrong options left to strike out
          if (wrongOptionsIndices.isNotEmpty) {
            // Randomly select one wrong option to strike out
            int randomWrongOptionIndex = wrongOptionsIndices[
                Random().nextInt(wrongOptionsIndices.length)];
            _struckOptions[randomWrongOptionIndex] = true;

            // Save the updated state in SharedPreferences
            prefs.setStringList('struckOptions',
                _struckOptions.map((e) => e.toString()).toList());
          }
        }
      });
    });
  }

  void _loadStruckOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedStruckOptions =
        prefs.getStringList('struckOptions') ?? [];

    setState(() {
      _struckOptions = storedStruckOptions.map((e) => e == 'true').toList();
    });
  }

  void _showRewardedAd() async {
    _rewardedAdManager.showRewardedAd();
    await _dialogueService.addRewardPoints(10);
    int updatedPoints = await _dialogueService.getRewardPoints();
    setState(() {
      _rewardPoints = updatedPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey[900], // Hint icon
          onPressed: _useHint,
          child: Image.asset("assets/images/hint.png"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
              FittedBox(
                // Wrap with FittedBox
                fit: BoxFit.fitHeight, // Adjust the fit as needed
                child: AnimatedFlipCounter(
                  value: _rewardPoints,
                  duration: const Duration(milliseconds: 2000),
                  textStyle: GoogleFonts.bitter(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ])
                .pOnly(right: 10, left: 10)
                .backgroundColor(Colors.blueGrey.shade900)
                .glassMorphic(),
          ],
        ),
        body: Column(
          children: <Widget>[
            if (adsControllerAvailable && !adsRemoved) ...[
              const SizedBox(
                height: 1,
              ),
              const BannerAdWidget(
                adSize: AdSize.banner,
              ),
              const SizedBox(
                height: 1,
              ),
            ] else
              const Text("Ad here").centered(),
            Expanded(
                child: FutureBuilder<Dialogue>(
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
            ))
          ],
        ));
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
      double width = constraints.maxWidth;
      double childAspectRatio = width > 600 ? 4 : 3;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 0,
          mainAxisSpacing: 8,
        ),
        itemCount: dialogue.options.length,
        itemBuilder: (context, index) {
          final option = dialogue.options[index];
          final isSelected = _selectedOptionIndex == index;
          final isCorrect = dialogue.rightOptionIndex == index;
          final isStruck = _struckOptions[index];

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: isSelected
                  ? (isCorrect ? Vx.green500 : Vx.red500)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    textStyle: GoogleFonts.bitter(fontSize: 18),
                    elevation: 0,
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed:
                      isStruck ? null : () => _handleAnswer(index, dialogue),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (isStruck)
                  Container(
                    height: 1,
                    color: Colors.red,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
          ).px2();
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

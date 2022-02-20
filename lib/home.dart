import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_sort/board.dart';
import 'package:word_sort/confetti.dart';
import 'package:word_sort/header.dart';
import 'package:word_sort/highScore.dart';
import 'package:word_sort/howTo.dart';
import 'package:word_sort/main.dart';
import 'package:word_sort/services/box.dart';
import 'package:word_sort/services/game.dart';
import 'package:word_sort/shared/button.dart';
import 'package:word_sort/shared/counter.dart';
import 'package:word_sort/submitForm.dart';
import 'package:word_sort/wordList.dart';

import 'models/box.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> with TickerProviderStateMixin {
  List<Box> _boxProps = [];
  bool loading = false;
  bool debugMode = false;
  bool solved = false;
  num steps = 0;
  late Timer? timer;
  String time = '';
  bool timerActive = false;
  bool showTimeScore = false;
  bool scoreSubmitted = false;
  bool showEmptyError = false;
  List<String> wordList = generateWordList();
  List<String> solutionCheck = [];
  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 10));
  late TextEditingController nameController;
  FirebaseAuth auth = FirebaseAuth.instance;
  late AnimationController animationController;
  late MediaQueryData mediaQuery;
  late bool smallScreen;
  late double screenWidth;

  CollectionReference highScoreSteps =
      FirebaseFirestore.instance.collection('highscore-steps');
  CollectionReference highScoreTime =
      FirebaseFirestore.instance.collection('highscore-time');

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);
    solutionCheck = [...wordList];
    nameController = TextEditingController();

    Future.delayed(Duration.zero, () {
      var query = MediaQuery.of(context);
      var small = query.size.width < 1024;
      var width = query.size.width;
      _boxProps = generateBoxProperties(wordList, small, width);
    });

    super.initState();
  }

  @override
  void dispose() {
    confettiController.dispose();
    animationController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const MyApp(),
      ),
    );
  }

  Future<void> addHighScoreSteps() {
    return highScoreSteps
        .add({
          'name': nameController.text,
          'steps': steps.toString(),
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addHighScoreTime() {
    // Call the user's CollectionReference to add a new user
    return highScoreTime
        .add({
          'name': nameController.text,
          'time': time,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  void _handleClick(Box selectedBox) {
    if (selectedBox.empty || solved) {
      return;
    }

    var updated = updateBoxesProp(_boxProps, selectedBox, steps);
    var newSolutionCheck = checkSolution(updated[0], [...wordList]);
    var newBoxProps = updated[0];
    var newSteps = updated[1];
    var startTimer = updated[2];

    if (!timerActive && startTimer) {
      print('Start timer');
      Timer.periodic(const Duration(seconds: 1), (seconds) {
        setState(() {
          time = seconds.tick.toString();
          timer = seconds;
          timerActive = true;
        });
      });
    }

    setState(() {
      _boxProps = newBoxProps;
      solved = newSolutionCheck.isEmpty;
      solutionCheck = newSolutionCheck;
      steps = newSteps;
    });
  }

  void handleSubmitHighScore() {
    displaySubmitForm(context);
  }

  void handleShowHighScore() {
    displayHighScore(context);
  }

  void handleShowHowToPlay() {
    displayHowTo(context);
  }

  displayHowTo(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return HowTo(handleCloseButton: () => Navigator.of(context).pop());
        });
  }

  displaySubmitForm(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SubmitForm(
            // context: context,
            showEmptyError: showEmptyError,
            handleCloseError: () {
              setState(() {
                showEmptyError = false;
              });
              Navigator.of(context).pop();
              displaySubmitForm(context);
            },
            handleCloseButton: () => Navigator.of(context).pop(),
            nameTextController: nameController,
            handleSendButton: () async {
              if (nameController.text == '') {
                setState(() {
                  showEmptyError = true;
                });
                Navigator.of(context).pop();
                displaySubmitForm(context);

                return;
              }

              Navigator.of(context).pop();

              setState(() {
                loading = true;
              });
              await auth.signInAnonymously();
              await addHighScoreSteps();
              await addHighScoreTime();
              await auth.signOut();
              setState(() {
                scoreSubmitted = true;
                loading = false;
              });
            });
      },
    );
  }

  displayHighScore(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return HighScore(
            handleCloseButton: () => Navigator.of(context).pop(),
            smallScreen: smallScreen,
            showTimeScore: showTimeScore,
            handleToggleScore: () => setState(() {
                  showTimeScore = !showTimeScore;
                  Navigator.of(context).pop();
                  displayHighScore(context);
                }),
            animationController: animationController,
            highScoreSteps: highScoreSteps,
            highScoreTime: highScoreTime);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    smallScreen = mediaQuery.size.width < 1024;
    screenWidth = mediaQuery.size.width;

    if (!debugMode && solved) {
      var currentTimer = timer;
      if (currentTimer != null) {
        currentTimer.cancel();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xff0b132b),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: smallScreen ? 50 : 100,
              ),
              const Header(),
              SizedBox(
                height: smallScreen ? 30 : 50,
              ),
              Confetti(solved: solved, confettiController: confettiController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!smallScreen)
                    WordList(solutionCheck: solutionCheck, wordList: wordList),
                  Board(
                      smallScreen: smallScreen,
                      screenWidth: screenWidth,
                      boxProperties: _boxProps,
                      debugMode: debugMode,
                      handleBoxClick: _handleClick),
                  if (!smallScreen)
                    Wrap(
                      spacing: 20,
                      direction: Axis.vertical,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (solved)
                          Button(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (loading)
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        value: animationController.value,
                                        semanticsLabel:
                                            'Linear progress indicator',
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                Color(0xffffffff)),
                                      ),
                                    ),
                                  Text(scoreSubmitted
                                      ? 'PLAY AGAIN'
                                      : 'SUBMIT SCORE'),
                                ]),
                            handleButtonPressed:
                                scoreSubmitted ? _reset : handleSubmitHighScore,
                            width: 150,
                            height: 60,
                            color: const Color.fromARGB(255, 73, 102, 190),
                          ),
                        Counter(
                            title: 'Timer',
                            showCounter: true,
                            counterItem: timerActive ? time : '0'),
                        Counter(
                            title: 'Steps',
                            showCounter: true,
                            counterItem: steps.toString()),
                        Button(
                          child: const Text(
                            'High score',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          handleButtonPressed: handleShowHighScore,
                          width: 150,
                          height: 60,
                          color: const Color(0xffffffff),
                        ),
                        Button(
                          child: const Text(
                            'HOW TO PLAY',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          handleButtonPressed: handleShowHowToPlay,
                          width: 150,
                          height: 60,
                          color: const Color(0xffffffff),
                        ),
                        if (debugMode)
                          Button(
                              child: const Text(
                                'Test',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                              handleButtonPressed: (() => setState(() {
                                    solved = true;
                                  })),
                              width: 150,
                              height: 60,
                              color: Colors.white),
                      ],
                    ),
                ],
              ),
              if (smallScreen)
                const SizedBox(
                  height: 30,
                ),
              if (smallScreen && solved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (loading)
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    value: animationController.value,
                                    semanticsLabel: 'Linear progress indicator',
                                    valueColor: const AlwaysStoppedAnimation(
                                        Color(0xffffffff)),
                                  ),
                                ),
                              Text(scoreSubmitted
                                  ? 'PLAY AGAIN'
                                  : 'SUBMIT SCORE'),
                            ]),
                        handleButtonPressed:
                            scoreSubmitted ? _reset : handleSubmitHighScore,
                        width: 280,
                        height: 60,
                        color: const Color.fromARGB(255, 73, 102, 190)),
                  ],
                ),
              if (smallScreen)
                const SizedBox(
                  height: 30,
                ),
              if (smallScreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WordList(
                      solutionCheck: solutionCheck,
                      wordList: wordList,
                      containerWidth: 60,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Counter(
                            title: 'Timer',
                            showCounter: true,
                            counterItem: timerActive ? time : '0'),
                        Counter(
                            title: 'Steps',
                            showCounter: true,
                            counterItem: steps.toString())
                      ],
                    ),
                  ],
                ),
              if (smallScreen)
                const SizedBox(
                  height: 30,
                ),
              if (smallScreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      child: const Text(
                        'HIGH SCORE',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      handleButtonPressed: handleShowHighScore,
                      width: 280,
                      height: 60,
                      color: const Color(0xffffffff),
                    )
                  ],
                ),
              const SizedBox(
                height: 30,
              ),
              if (smallScreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                      child: const Text(
                        'HOW TO PLAY',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      handleButtonPressed: handleShowHowToPlay,
                      width: 280,
                      height: 60,
                      color: const Color(0xffffffff),
                    )
                  ],
                ),
              const SizedBox(
                height: 30,
              ),
              if (smallScreen && debugMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (debugMode)
                      Button(
                          child: const Text(
                            'Test',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          handleButtonPressed: (() => setState(() {
                                solved = true;
                              })),
                          width: 280,
                          height: 60,
                          color: Colors.white)
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

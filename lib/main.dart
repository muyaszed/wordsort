import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:confetti/confetti.dart';
import './models/box.dart';
import './services/box.dart';
import './services/game.dart';
import './constants//box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordSort Demo',
      theme: ThemeData(
          // primarySwatch: const Color(0xff89ABE3),
          ),
      home: const MyHomePage(title: 'Word Sort'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Box> _boxProps = [];
  bool debugMode = false;
  bool solved = false;
  num steps = 0;
  late Timer? timer;
  String time = '';
  bool timerActive = false;
  bool showTimeScore = false;
  List<String> wordList = generateWordList();
  List<String> solutionCheck = [];
  final ConfettiController _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 10));
  late TextEditingController nameController;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _boxProps = generateBoxProperties(wordList);
    solutionCheck = [...wordList];
    nameController = TextEditingController();
    // _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    nameController.dispose();
    super.dispose();
  }

  CollectionReference highscoreSteps =
      FirebaseFirestore.instance.collection('highscore-steps');
  CollectionReference highscoreTime =
      FirebaseFirestore.instance.collection('highscore-time');

  Future<void> addHighScoreSteps() {
    // Call the user's CollectionReference to add a new user
    return highscoreSteps
        .add({
          'name': nameController.text,
          'steps': steps.toString(),
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addHighScoreTime() {
    // Call the user's CollectionReference to add a new user
    return highscoreTime
        .add({
          'name': nameController.text,
          'time': time,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  void _handleClick(Box selectedBox) {
    if (!timerActive) {
      Timer.periodic(const Duration(seconds: 1), (seconds) {
        setState(() {
          time = seconds.tick.toString();
          timer = seconds;
          timerActive = true;
        });
      });
    }

    if (selectedBox.empty || solved) {
      return;
    }

    var newBoxProps = updateBoxesProp(_boxProps, selectedBox);
    var newSolutionCheck = checkSolution(newBoxProps, [...wordList]);

    setState(() {
      _boxProps = newBoxProps;
      solved = newSolutionCheck.isEmpty;
      solutionCheck = newSolutionCheck;
      steps++;
    });
  }

  void handleSubmitHighScore() {
    _displayDialog(context);
  }

  void handleShowHighScore() {
    _displayHighScore(context);
  }

  _displayDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Material(
            color: const Color.fromARGB(220, 11, 19, 43),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
              // color: const Color(0x0000007f),
              child: Center(
                  child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: const Color(0xff1c2541),
                          ),
                          child: const Center(
                              child: Text(
                            'X',
                            style: TextStyle(
                                color: Color(0xffffffff), fontSize: 44),
                          )),
                        ),
                      )
                    ],
                  ),
                  SimpleDialog(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        height: 60,
                        child: TextField(
                          style: const TextStyle(fontSize: 20),
                          controller: nameController,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Your Name',
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 280,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 73, 102, 190)),
                      onPressed: () async {
                        await auth.signInAnonymously();
                        await addHighScoreSteps();
                        await addHighScoreTime();
                        await auth.signOut();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "SEND",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ),
        );
      },
    );
  }

  _displayHighScore(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        CollectionReference highscoreSteps =
            FirebaseFirestore.instance.collection('highscore-steps');
        CollectionReference highscoreTime =
            FirebaseFirestore.instance.collection('highscore-time');

        return SafeArea(
          child: Material(
            color: const Color.fromARGB(220, 11, 19, 43),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
              // color: const Color(0x0000007f),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: const Color(0xff1c2541),
                          ),
                          child: const Center(
                              child: Text(
                            'X',
                            style: TextStyle(
                                color: Color(0xffffffff), fontSize: 44),
                          )),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                          height: 60,
                          child: Text(
                              showTimeScore ? 'TIME SCORE' : 'STEPS SCORE',
                              style: const TextStyle(
                                  fontSize: 30, color: Color(0xffffffff)))),
                      if (!showTimeScore)
                        FutureBuilder<QuerySnapshot>(
                          future: highscoreSteps.get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Something went wrong");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Column(
                                children: List.generate(
                                  snapshot.data?.docs.length ?? 0,
                                  (index) => Container(
                                    width: 500,
                                    color:
                                        const Color.fromARGB(255, 241, 204, 38),
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: 250,
                                              height: 60,
                                              child: Text(
                                                snapshot.data?.docs[index]
                                                        .get('name')
                                                        .toString()
                                                        .toUpperCase() ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                          Container(
                                              alignment: Alignment.center,
                                              width: 250,
                                              height: 60,
                                              child: Text(
                                                snapshot.data?.docs[index]
                                                        .get('steps')
                                                        .toString()
                                                        .toUpperCase() ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                        ]),
                                  ),
                                ),
                              );
                            }

                            return const Text("loading");
                          },
                        ),
                      if (showTimeScore)
                        FutureBuilder<QuerySnapshot>(
                          future: highscoreTime.get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Something went wrong");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Column(
                                children: List.generate(
                                  snapshot.data?.docs.length ?? 0,
                                  (index) => Container(
                                    width: 500,
                                    color:
                                        const Color.fromARGB(255, 241, 204, 38),
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: 250,
                                              height: 60,
                                              child: Text(
                                                snapshot.data?.docs[index]
                                                        .get('name')
                                                        .toString()
                                                        .toUpperCase() ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                          Container(
                                              alignment: Alignment.center,
                                              width: 250,
                                              height: 60,
                                              child: Text(
                                                snapshot.data?.docs[index]
                                                        .get('time')
                                                        .toString()
                                                        .toUpperCase() ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                        ]),
                                  ),
                                ),
                              );
                            }

                            return const Text("loading");
                          },
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      if (showTimeScore)
                        SizedBox(
                          width: 150,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromARGB(255, 73, 102, 190)),
                            onPressed: () => setState(() {
                              showTimeScore = false;
                              Navigator.of(context).pop();
                              _displayHighScore(context);
                            }),
                            child: const Text('STEPS'),
                          ),
                        ),
                      if (!showTimeScore)
                        SizedBox(
                          width: 150,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromARGB(255, 73, 102, 190)),
                            onPressed: () => setState(() {
                              showTimeScore = true;
                              Navigator.of(context).pop();
                              _displayHighScore(context);
                            }),
                            child: const Text('TIME'),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget generateBox(Box box) {
    // print('${solutionCheck} in generate box');
    return Positioned(
        top: box.startPosX,
        left: box.startPosY,
        child: GestureDetector(
          onTapDown: (detail) => _handleClick(box),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DelayedDisplay(
                delay: Duration(milliseconds: box.delay),
                child: Container(
                  width: tileWidth,
                  height: tileHeight,
                  decoration: BoxDecoration(
                    color: box.color,
                  ),
                ),
              ),
              Text(
                box.letter.toUpperCase(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 252, 252, 252),
                  fontSize: 22,
                ),
              ),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'x: ' + box.tile.x.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 20,
                    child: Text(
                      'y: ' + box.tile.y.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 252, 252, 252)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 70,
                    child: Text(
                      'empty: ' + box.empty.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    )),
              if (debugMode)
                Positioned(
                    left: 0,
                    top: 80,
                    child: Text(
                      'Selected: ' + box.selected.toString(),
                      style: TextStyle(
                          color: box.empty
                              ? const Color.fromARGB(255, 7, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255)),
                    ))
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (solved) {
      _controllerCenter.play();
      var currentTimer = timer;
      if (currentTimer != null) {
        currentTimer.cancel();
      }
    }

    return Scaffold(
        backgroundColor: const Color(0xff0b132b),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("WORDSORT",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 24,
                      )),
                ],
              ),
              SizedBox(
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality
                      .explosive, // don't specify a direction, blast randomly
                  shouldLoop:
                      true, // start again as soon as the animation is finished
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ], // manually specify the colors to be used
                  createParticlePath: drawStar, // define a custom shape/path.
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Wrap(
                    spacing: 20,
                    direction: Axis.vertical,
                    children: wordList.map((e) {
                      TextStyle style;

                      if (solutionCheck.contains(e)) {
                        style = const TextStyle(color: Color(0xffffffff));
                      } else {
                        style = const TextStyle(
                            color: Color.fromARGB(255, 146, 212, 120));
                      }

                      return Container(
                        alignment: Alignment.center,
                        width: 150,
                        child: Text(
                          e.toUpperCase(),
                          style: style,
                        ),
                      );
                    }).toList(),
                  ),
                  Wrap(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          color: const Color(0xff0b132b),
                          width: (5 * tileWidth) + (4 * tileGap),
                          height: (5 * tileHeight) + (4 * tileGap),
                          child: Stack(
                            alignment: Alignment.center,
                            children: _boxProps
                                .map((box) => generateBox(box))
                                .toList(),
                          )),
                    ],
                  ),
                  Wrap(
                    spacing: 20,
                    direction: Axis.vertical,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (solved)
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(255, 73, 102, 190)),
                              onPressed: handleSubmitHighScore,
                              child: const Text('SUBMIT'),
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          const Text("TIMER",
                              style: TextStyle(
                                  color: Color(0xffffffff), fontSize: 22)),
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(left: 35, right: 35),
                            alignment: Alignment.center,
                            child: Text(
                              timerActive ? time : '0',
                              style: const TextStyle(fontSize: 26),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xffffffff),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "STEPS",
                            style: TextStyle(
                                color: Color(0xffffffff), fontSize: 22),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            child: Text(
                              steps.toString(),
                              style: const TextStyle(fontSize: 26),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: handleShowHighScore,
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 60,
                          child: const Text(
                            'HIGH SCORE',
                            style: TextStyle(fontSize: 18),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xffffffff),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

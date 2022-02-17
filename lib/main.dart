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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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
  final ConfettiController _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 10));
  late TextEditingController nameController;
  FirebaseAuth auth = FirebaseAuth.instance;
  late AnimationController controller;
  late MediaQueryData mediaQuery;
  late bool smallScreen;
  late double screenWidth;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
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
    _controllerCenter.dispose();
    controller.dispose();
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
                  if (showEmptyError)
                    SizedBox(
                      width: 300,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Name cannot be empty",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 230, 74, 74)),
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showEmptyError = false;
                                  });
                                  Navigator.of(context).pop();
                                  _displayDialog(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 20,
                                  height: 20,
                                  child: const Text('x'),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(10)),
                                ))
                          ]),
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
                        if (nameController.text == '') {
                          setState(() {
                            showEmptyError = true;
                          });
                          Navigator.of(context).pop();
                          _displayDialog(context);

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                      ),
                    ],
                  ),
                  if (smallScreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromARGB(255, 73, 102, 190)),
                            onPressed: () => setState(() {
                              showTimeScore = !showTimeScore;
                              Navigator.of(context).pop();
                              _displayHighScore(context);
                            }),
                            child: Text(showTimeScore ? 'STEPS' : 'TIME'),
                          ),
                        ),
                      ],
                    ),
                  if (smallScreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: Text(
                                showTimeScore ? 'TIME SCORE' : 'STEPS SCORE',
                                style: const TextStyle(
                                    fontSize: 30, color: Color(0xffffffff)))),
                      ],
                    ),
                  if (!smallScreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: Text(
                                showTimeScore ? 'TIME SCORE' : 'STEPS SCORE',
                                style: const TextStyle(
                                    fontSize: 30, color: Color(0xffffffff)))),
                        SizedBox(
                          width: 150,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromARGB(255, 73, 102, 190)),
                            onPressed: () => setState(() {
                              showTimeScore = !showTimeScore;
                              Navigator.of(context).pop();
                              _displayHighScore(context);
                            }),
                            child: Text(showTimeScore ? 'STEPS' : 'TIME'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              var query = snapshot.data?.docs ?? [];
                              var data = List.generate(
                                  query.length,
                                  (index) => HighScoreSteps(
                                      query[index].get('name'),
                                      query[index].get('steps')));
                              data.sort((a, b) => a.steps.compareTo(b.steps));

                              return Column(
                                children: List.generate(
                                  snapshot.data?.docs.length ?? 0,
                                  (index) => Container(
                                    width: smallScreen ? 250 : 500,
                                    color:
                                        const Color.fromARGB(255, 241, 204, 38),
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: smallScreen ? 50 : 250,
                                              height: 60,
                                              child: Text(
                                                data[index].name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                          Container(
                                              alignment: Alignment.center,
                                              width: smallScreen ? 50 : 250,
                                              height: 60,
                                              child: Text(
                                                data[index].steps,
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

                            return CircularProgressIndicator(
                              value: controller.value,
                              semanticsLabel: 'Linear progress indicator',
                            );
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
                              var query = snapshot.data?.docs ?? [];
                              var data = List.generate(
                                  query.length,
                                  (index) => HighScoreTime(
                                      query[index].get('name'),
                                      query[index].get('time')));
                              data.sort((a, b) => a.time.compareTo(b.time));
                              return Column(
                                children: List.generate(
                                  snapshot.data?.docs.length ?? 0,
                                  (index) => Container(
                                    width: smallScreen ? 250 : 500,
                                    color:
                                        const Color.fromARGB(255, 241, 204, 38),
                                    alignment: Alignment.center,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: smallScreen ? 50 : 250,
                                              height: 60,
                                              child: Text(
                                                data[index].name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                ),
                                              )),
                                          Container(
                                              alignment: Alignment.center,
                                              width: smallScreen ? 50 : 250,
                                              height: 60,
                                              child: Text(
                                                data[index].time,
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
                  width: smallScreen
                      ? tileWidthSmall + ((screenWidth - 320) / 12.5)
                      : tileWidth,
                  height: smallScreen
                      ? tileHeightSamll + ((screenWidth - 320) / 12.5)
                      : tileHeight,
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
    mediaQuery = MediaQuery.of(context);
    smallScreen = mediaQuery.size.width < 1024;
    screenWidth = mediaQuery.size.width;

    if (solved) {
      _controllerCenter.play();

      if (!debugMode) {
        var currentTimer = timer;
        if (currentTimer != null) {
          currentTimer.cancel();
        }
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
                height: smallScreen ? 30 : 50,
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
                  if (!smallScreen)
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
                          width: smallScreen
                              ? (5 * tileWidthSmall) +
                                  (4 * tileGap) +
                                  (5 * (screenWidth - 320) / 12.5)
                              : (5 * tileWidth) + (4 * tileGap),
                          height: smallScreen
                              ? (5 * tileHeightSamll) +
                                  (4 * tileGap) +
                                  (5 * (screenWidth - 320) / 12.5)
                              : (5 * tileHeight) + (4 * tileGap),
                          child: Stack(
                            alignment: Alignment.center,
                            children: _boxProps
                                .map((box) => generateBox(box))
                                .toList(),
                          )),
                    ],
                  ),
                  if (!smallScreen)
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
                                      primary: const Color.fromARGB(
                                          255, 73, 102, 190)),
                                  onPressed: scoreSubmitted
                                      ? _reset
                                      : handleSubmitHighScore,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (loading)
                                          SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              value: controller.value,
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
                                      ])),
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
                              margin:
                                  const EdgeInsets.only(left: 35, right: 35),
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
                        ),
                        if (debugMode)
                          GestureDetector(
                            onTap: (() => setState(() {
                                  solved = true;
                                })),
                            child: Container(
                              alignment: Alignment.center,
                              width: 150,
                              height: 60,
                              child: const Text(
                                'Test',
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
              if (smallScreen)
                const SizedBox(
                  height: 30,
                ),
              if (smallScreen && solved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 73, 102, 190)),
                          onPressed:
                              scoreSubmitted ? _reset : handleSubmitHighScore,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (loading)
                                  SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      value: controller.value,
                                      semanticsLabel:
                                          'Linear progress indicator',
                                      valueColor: const AlwaysStoppedAnimation(
                                          Color(0xffffffff)),
                                    ),
                                  ),
                                Text(scoreSubmitted
                                    ? 'PLAY AGAIN'
                                    : 'SUBMIT SCORE'),
                              ])),
                    ),
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
                    Wrap(
                      spacing: 20,
                      alignment: WrapAlignment.center,
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
                          width: 60,
                          child: Text(
                            e.toUpperCase(),
                            style: style,
                          ),
                        );
                      }).toList(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("TIMER",
                                style: TextStyle(
                                    color: Color(0xffffffff), fontSize: 22)),
                            Container(
                              width: 80,
                              height: 80,
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
                    GestureDetector(
                      onTap: handleShowHighScore,
                      child: Container(
                        alignment: Alignment.center,
                        width: 280,
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
                    ),
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
                      GestureDetector(
                        onTap: (() => setState(() {
                              solved = true;
                            })),
                        child: Container(
                          alignment: Alignment.center,
                          width: 280,
                          height: 60,
                          child: const Text(
                            'Test',
                            style: TextStyle(fontSize: 18),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xffffffff),
                          ),
                        ),
                      )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class HighScoreTime {
  late String name;
  late String time;

  HighScoreTime(this.name, this.time);
}

class HighScoreSteps {
  late String name;
  late String steps;

  HighScoreSteps(this.name, this.steps);
}
